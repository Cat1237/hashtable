# frozen_string_literal: true

require 'benchmark'

# module HashTable
module HashTable

  EXPAND_KEY_COUNT_CONST = {
    8 => [0, 0],
    16 => [6, 9],
    32 => [8, 17],
    64 => [13, 33],
    128 => [23, 65],
    256 => [44, 129],
    512 => [86, 257],
    1024 => [171, 513],
    2048 => [341, 1025],
    4096 => [682, 2049],
    8192 => [1364, 4097],
    16_384 => [2729, 8193],
    32_768 => [5459, 16_385],
    65_536 => [10_920, 32_769],
    131_072 => [21_842, 65_537],
    262_144 => [43_687, 131_073],
    524_288 => [87_377, 262_145],
    1_048_576 => [174_758, 524_289],
    2_097_152 => [349_520, 1_048_577],
    4_194_304 => [699_045, 2_097_153],
    8_388_608 => [1_398_095, 4_194_305],
    16_777_216 => [2_796_196, 8_388_609],
    33_554_432 => [5_592_398, 16_777_217],
    67_108_864 => [11_184_803, 33_554_433],
    134_217_728 => [22_369_613, 67_108_865],
    268_435_456 => [44_739_234, 134_217_729],
    536_870_912 => [89_478_476, 268_435_457],
    1_073_741_824 => [178_956_961, 536_870_913],
    2_147_483_648 => [357_913_931, 1_073_741_825],
    4_294_967_296 => [715_827_872, 2_147_483_649],
    8_589_934_592 => [1_431_655_754, 4_294_967_297],
    17_179_869_184 => [2_863_311_519, 8_589_934_593],
    34_359_738_368 => [5_726_623_049, 17_179_869_185],
    68_719_476_736 => [11_453_246_110, 34_359_738_369],
    137_438_953_472 => [22_906_492_232, 68_719_476_737],
    274_877_906_944 => [45_812_984_477, 137_438_953_473],
    549_755_813_888 => [91_625_968_967, 274_877_906_945],
    1_099_511_627_776 => [183_251_937_948, 549_755_813_889]
  }.freeze
  # HashTable
  # @abstract
  class HashTable
    attr_reader :size

    # @return [HashTable]
    # @param  [object] p_value placeholder value with @buckets_v
    # @param  [Bool] Does it need to be expanded
    def self.new_from_vlaue_placeholder(count = 0, p_value = nil, expand: false)
      new(count, p_value: p_value, expand: expand)
    end

    # @return [HashTable]
    # @param  [Integer] count of entries
    # @param  [object] p_key placeholder key with @buckets_k
    # @param  [object] p_value placeholder value with @buckets_v
    # @param  [Bool] Does it need to be expanded
    def initialize(count = 0, p_key: nil, p_value: nil, expand: false)
      capacity = calculate_count(count, expand: expand)
      @buckets_k = Array.new(capacity, p_key)
      @buckets_v = Array.new(capacity, p_value)
      @present = SparseBitArray.new
      @deleted = SparseBitArray.new
      @expand = expand
      @size = 0
    end

    def num_entries
      raise 'count must less than 2_863_311_519' if size > 2_863_311_519
      return size unless @expand

      es = EXPAND_KEY_COUNT_CONST[capacity]
      size - es[0] + es[1]
    end

    def keys
      @buckets_k
    end

    def values
      @buckets_v
    end

    def empty?
      size.zero?
    end

    def capacity
      @buckets_k.length
    end

    # @return [Integer] Find the entry whose key has the specified hash value,
    # using the specified traits defining hash function and equality.
    # @param  [object] key
    # @param  [object] traits
    def find(key, traits = IdentityHashTraits.new)
      nums = capacity - 1
      h = traits.hash_lookup_key(key) & nums
      i = h
      loop do
        bucket = @buckets_k[i]
        return i if !bucket.nil? && present?(i) && traits.storage_key_to_lookup_key(bucket) == key

        break unless deleted?(i)

        i = (i + 1) & nums
        break if i == h
      end
      i
    end

    # @return [Integer] internal key
    # Set the entry using a key type that the specified Traits can convert from a real key to an internal key.
    # @param  [object] key
    # @param  [object] value
    # @param  [object] traits
    def set(key, value, traits = IdentityHashTraits.new)
      set_as_interal(key, traits, value)
    end

    def get(key, traits = IdentityHashTraits.new)
      i = find(key, traits)
      @buckets_v[i]
    end

    # @return [Integer] internal key
    # Set the entry using a key type that the specified Traits can convert from a real key to an internal key.
    # @param  [object] key
    # @param  [object] traits
    def add(key, traits = IdentityHashTraits.new)
      set_as_interal(key, traits)
    end

    # @return [Array<Integer>] internal key
    # Set the entry using a key type that the specified Traits can convert from a real key to an internal key.
    # @param  [object] key
    # @param  [object] traits
    def adds(keys, traits = IdentityHashTraits.new)
      keys.map { |key| set_as_interal(key, traits) }
    end

    protected

    attr_reader :present, :deleted, :buckets_k, :buckets_v

    def present?(key)
      @present.test?(key)
    end

    def deleted?(key)
      @present.test?(key)
    end

    # @return [Integer] internal key
    # Set the entry using a key type that the specified Traits can convert from a real key to an internal key.
    # @param  [object] key
    # @param  [object] traits
    # @param  [object] value
    # @param  [object] internal_key
    def set_as_interal(key, traits = IdentityHashTraits.new, value = nil, internal_key = nil)
      index = find(key, traits)
      bucket_k = @buckets_k[index]
      if bucket_k.nil?
        raise ArgumentError if present?(index)

        @buckets_k[index] = bucket_k = internal_key.nil? ? traits.lookup_key_to_storage_key(key) : internal_key
        @buckets_v[index] = traits.lookup_key_to_storage_value(bucket_k, value)
        @present.set(index)
        @deleted.reset(index)
        @size += 1
        grow(traits)
      else
        raise ArgumentError unless present?(index) || traits.storage_key_to_lookup_key(bucket_k) == key

        @buckets_v[index] = traits.lookup_key_to_storage_value(bucket_k, value)
      end
      bucket_k
    end

    private

    def need_grow(size, count, expand: false)
      raise 'count must less than 2_863_311_519' if count > 2_863_311_519

      count *= 2
      return size >= count / 3 + 1 unless expand

      size >= EXPAND_KEY_COUNT_CONST[count][0]
    end

    def calculate_count(size, expand: false)
      return 8 if size < 6
      raise 'count must less than 2_863_311_519' if size > 2_863_311_519

      if expand
        EXPAND_KEY_COUNT_CONST.each_pair { |key, e| return key / 2 if size < e[0] }
      else
        2**(size * 3 / 2 + 1 - 1).bit_length
      end
    end

    def grow(traits = IdentityHashTraits.new)
      return unless need_grow(size, capacity, expand: @expand)

      new_map = HashTable.new(size, expand: @expand)
      @present.each do |i|
        key = @buckets_k[i]
        lookup_key = traits.storage_key_to_lookup_key(key)
        # Private methods cannot be called with an explicit receiver and protected ones can.
        new_map.set_as_interal(lookup_key, traits, @buckets_v[i], key)
      end

      @buckets_k = new_map.buckets_k
      @buckets_v = new_map.buckets_v
      @present = new_map.present
      @deleted = new_map.deleted
    end
  end
end
