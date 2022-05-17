# Hashtable
[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://raw.githubusercontent.com/Cat1237/hashtable/main/LICENSE)&nbsp;

`HashTable` - This provides a hash table data structure that is specialized for handling key/value pairs. This does some funky memory allocation and hashing things to make it extremely efficient, storing the key/value with `SparseBitArray`.

`SparseBitArray` - is an implementation of a bitmap that is sparse by only storing the elements that have non-zero bits set.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hashtable'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install hashtable

## Usage

### `SparseBitArray`

```ruby
e = HashTable::SparseBitArrayElement.new
# Set, Test and Reset a bit in the bitmap
e.set(23)
e.test?(17)
e.reset(4000)

# The index of the first set bit
e.first
# The index of the last set bit
e.last


(0..128).to_a.each_index do |i|
    e.set(i)
end
# Enumerator
e.each do |index|
  p "#{index}----"
end
```

### HashTable

Store numbers：

```ruby
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

table = HashTable::HashTable.new(2)
traits = Traits.new
table.set(3, 7, )
table.set(4, 5, traits)
table.set(5, 6, traits)
table.set(6, 7, traits)
table.set(8, 9, traits)
table.set(9, 19, traits)
```

Store strings：

```ruby
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
    @string_table[offset..-1][/[^\0]+/]
  end
end


table = HashTable::HashTable.new(2)
traits = StringTraits.new
table.set('ViewController64.h', 'ViewController64.h', traits)
table.set('ViewController65.h', 'ViewController65.h', traits)
table.set('ViewController66.h', 'ViewController66.h', traits)
table.set('ViewController67.h', 'ViewController67.h', traits)
table.set('ViewController68.h', 'ViewController68.h', traits)
table.set('ViewController69.h', 'ViewController69.h', traits)
# ViewController64.h
table.get('ViewController64.h', traits)
# \u0000ViewController64.h\u0000ViewController65.h\u0000ViewController66.h\u0000ViewController67.h\u0000ViewController68.h\u0000ViewController69.h\u0000
p traits.string_table
```

Store just key string：

```ruby
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
    @string_table[offset..-1][/[^\0]+/]
  end
end


table = HashTable::HashTable.new(2)
traits = StringTraits.new

(0..31).each do |i|
   table.add("ViewController#{i}.h", traits)
end
# 32
p table.size
# 64
p table.capacity
# 32
p table.num_entries
```

Store strings and expand capacity:

- num_entries = capacity + 1
- capacity = capacity * 2
- capacity is power_of_two

```ruby
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
    @string_table[offset..-1][/[^\0]+/]
  end
end

table = HashTable::HashTable.new(8192, expand: true)
traits = StringTraits.new
buckets = (0..1363).map do |i|
    a = ["ViewController#{i}.h", "/Users/ws/Desktop/llvm/TestAndTestApp/TestAndTestApp/Group/h2/#{i}", "ViewController#{i}.h"]
    table.adds(a, traits)
end
# 2728
p table.size
# 8192
p table.capacity
# 5461
p table.num_entries
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Cat1237/hashtable. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[Cat1237]/hashtable/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Hashtable project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/Cat1237/hashtable/blob/master/CODE_OF_CONDUCT.md).
