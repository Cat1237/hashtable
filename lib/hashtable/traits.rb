# frozen_string_literal: true

# module HashTable
module HashTable
  class Traits
    def hash_lookup_key(key)
      key
    end

    def lookup_key_to_storage_key(key)
      key
    end

    def storage_key_to_lookup_key(key)
      key
    end
  end

  class StringTraits
    attr_reader :string_table, :string_index

    def initialize
      @string_table = "\0"
      @string_index = 1
    end

    def hash_lookup_key(key)
      result = 0
      key.each_byte { |byte| result += byte * 13 }
      result
    end

    def lookup_key_to_storage_key(key)
      @string_table += "#{key}\0"
      old_si = @string_index
      @string_index += key.length + 1
      old_si
    end

    def storage_key_to_lookup_key(offset)
      @string_table[offset..][/[^\0]+/]
    end
  end

  class StringTraits2
    attr_reader :string_table, :buckets, :hash_h

    def initialize
      @string_table = "\0"
      @string_index = 1
      @buckets = {}
      @hash_h = {}
    end

    def hash_lookup_key(key)
      return @hash_h[key] unless @hash_h[key].nil?

      result = 0
      key.each_byte { |byte| result += byte * 13 }
      @hash_h[key] = result
      result
    end

    def lookup_key_to_storage_key(key)
      return @buckets[key] unless @buckets[key].nil?

      @string_table += "#{key}\0"
      old_si = @string_index
      @string_index += key.length + 1
      @buckets[key] = old_si
      old_si
    end

    def lookup_key_and_value(key, value)
      value.inject([@buckets[key]]) do |sum, v|
        sum << lookup_key_to_storage_key(v)
      end
    end

    def storage_key_to_lookup_key(offset)
      @string_table[offset..][/[^\0]+/]
    end
  end
end
