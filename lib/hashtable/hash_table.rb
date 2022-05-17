# frozen_string_literal: true

# module HashTable
module HashTable
  # HashTable
  # @abstract
  class HashTable
    # @return [Integer] nums of HashTable entries
    attr_reader :num_entries

    def initialize(capacity = 8, expand: false)
      capacity = capacity < 8 ? 8 : 2**(capacity - 1).bit_length
      @buckets = Array.new(capacity)
      @present = SparseBitArray.new
      @deleted = SparseBitArray.new
      @expand = expand
      @num_entries = 0
    end

    def size
      @present.count
    end

    def empty?
      size.zero?
    end

    def capacity
      @buckets.length
    end

    # @return [Integer] Find the entry whose key has the specified hash value,
    # using the specified traits defining hash function and equality.
    # @param  [object] key
    # @param  [object] traits
    def find(key, traits)
      raise ArgumentError, 'traits must respond to hash_lookup_key method' unless traits.respond_to?(:hash_lookup_key)

      unless traits.respond_to?(:storage_key_to_lookup_key)
        raise ArgumentError,
              'traits must respond to storage_key_to_lookup_key method'
      end
      h = traits.hash_lookup_key(key) % capacity
      i = h
      fisrt_unsed = nil
      loop do
        if present?(i)
          return i if !@buckets[i].nil? && traits.storage_key_to_lookup_key(@buckets[i].first) == key
        else
          fisrt_unsed = i if fisrt_unsed.nil?
          break unless deleted?(i)
        end
        i = (i + 1) % capacity
        break if i == h
      end
      raise ArgumentError if fisrt_unsed.nil?

      fisrt_unsed
    end

    # @return [Integer] internal key
    # Set the entry using a key type that the specified Traits can convert from a real key to an internal key.
    # @param  [object] key
    # @param  [object] value
    # @param  [object] traits
    def set(key, value, traits)
      set_as_interal(key, traits, value)
    end

    def get(key, traits)
      i = find(key, traits)
      bucket = @buckets[i]
      raise ArgumentError if bucket.nil? || bucket.empty?

      bucket.last
    end

    # @return [Integer] internal key
    # Set the entry using a key type that the specified Traits can convert from a real key to an internal key.
    # @param  [object] key
    # @param  [object] traits
    def add(key, traits)
      set_as_interal(key, traits)
    end

    # @return [Array<Integer>] internal key
    # Set the entry using a key type that the specified Traits can convert from a real key to an internal key.
    # @param  [object] key
    # @param  [object] traits
    def adds(keys, traits)
      (keys || []).map { |key| set_as_interal(key, traits) }
    end

    protected

    attr_reader :present, :deleted, :buckets

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
    def set_as_interal(key, traits, value = nil, internal_key = nil)
      unless traits.respond_to?(:lookup_key_to_storage_key)
        raise ArgumentError,
              'traits must respond to lookup_key_to_storage_key method'
      end
      unless traits.respond_to?(:storage_key_to_lookup_key)
        raise ArgumentError,
              'traits must respond to storage_key_to_lookup_key method'
      end

      index = find(key, traits)
      bucket = @buckets[index] ||= []
      if bucket.empty?
        raise ArgumentError if present?(index)

        bucket[0] = internal_key.nil? ? traits.lookup_key_to_storage_key(key) : internal_key
        bucket[1] = value unless value.nil?
        @present.set(index)
        @deleted.reset(index)
        grow(traits)
      else
        raise ArgumentError unless present?(index)
        raise ArgumentError unless traits.storage_key_to_lookup_key(@buckets[index].first) == key

        bucket[1] = value unless value.nil?
      end
      bucket[0]
    end

    private

    def grow(traits)
      unless traits.respond_to?(:storage_key_to_lookup_key)
        raise ArgumentError,
              'traits must respond to storage_key_to_lookup_key method'
      end
      @num_entries += 1
      n = 2**(@num_entries - 1).bit_length
      m = n < 8 ? 8 : n
      max_load = m * 2 / 3 + 1
      entries = @expand ? num_entries : size
      return if entries < max_load

      @num_entries = m + 1 if @expand
      new_capacity = m * 2
      return if new_capacity <= capacity

      new_map = HashTable.new(new_capacity, expand: @expand)
      @present.each do |i|
        lookup_key = traits.storage_key_to_lookup_key(@buckets[i].first)
        # Private methods cannot be called with an explicit receiver and protected ones can.
        new_map.set_as_interal(lookup_key, traits, @buckets[i][1], @buckets[i].first)
      end
      @buckets = new_map.buckets
      @present = new_map.present
      @deleted = new_map.deleted
    end
  end
end
