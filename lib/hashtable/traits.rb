# frozen_string_literal: false

# module HashTable
module HashTable
  # IdentityHashTraits
  class IdentityHashTraits
    define_method(:hash_lookup_key) { |key| key }
    define_method(:lookup_key_to_storage_key) { |key| key }
    define_method(:storage_key_to_lookup_key) { |key| key }
    define_method(:lookup_key_to_storage_value) { |_key, value| value }
  end

  # StringIdentityHashTraits
  class StringIdentityHashTraits < IdentityHashTraits
    attr_reader :string_table, :buckets

    def initialize(&block)
      super
      @string_table = "\0"
      @buckets = {}
      @indexs = {}
    end

    def hash_lookup_key(key)
      key.downcase.bytes.inject(:+) * 13
    end

    def lookup_key_to_storage_key(key)
      return @buckets[key] unless @buckets[key].nil?

      old_si = @string_table.length
      @buckets[key] = old_si
      @string_table << "#{key}\0".b
      @indexs[old_si] = key
      old_si
    end

    def storage_key_to_lookup_key(offset)
      return @indexs[offset] unless @indexs[offset].nil?

      key = @string_table[offset..][/[^\0]+/]
      @indexs[offset] = key
      key
    end
  end

  # StringHashTraits
  class StringHashTraits < StringIdentityHashTraits
    attr_reader :string_table, :buckets

    def initialize(&block)
      super
      @block = block
    end

    def lookup_key_to_storage_value(key, values)
      return if values.nil? || values.empty?

      bs = values.map { |v| lookup_key_to_storage_key(v) }.unshift(key)
      return bs if @block.nil?

      @block.call(bs)
    end
  end
end
