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
table = HashTable::HashTable.new(2)
table.set(3, 7, HashTable::IdentityHashTraits.new)
table.set(4, 5, HashTable::IdentityHashTraits.new)
table.set(5, 6, HashTable::IdentityHashTraits.new)
table.set(6, 7, HashTable::IdentityHashTraits.new)
table.set(8, 9, HashTable::IdentityHashTraits.new)
table.set(9, 19, HashTable::IdentityHashTraits.new)
expect(table.size).to eq(6)
expect(table.get(3, HashTable::IdentityHashTraits.new)).to eq(7)
expect(table.get(4, HashTable::IdentityHashTraits.new)).to eq(5)
expect(table.get(5, HashTable::IdentityHashTraits.new)).to eq(6)
expect(table.get(6, HashTable::IdentityHashTraits.new)).to eq(7)
expect(table.get(8, HashTable::IdentityHashTraits.new)).to eq(9)
expect(table.get(9, HashTable::IdentityHashTraits.new)).to eq(19)
expect(table.capacity).to eq(16)
```

Store strings：

```ruby
table = HashTable::HashTable.new(2)
traits = HashTable::StringIdentityHashTraits.new
table.set('ViewController64.h', 'ViewController64.h', traits)
table.set('ViewController65.h', 'ViewController65.h', traits)
table.set('ViewController66.h', 'ViewController66.h', traits)
table.set('ViewController67.h', 'ViewController67.h', traits)
table.set('ViewController68.h', 'ViewController68.h', traits)
table.set('ViewController69.h', 'ViewController69.h', traits)
expect(table.size).to eq(6)
expect(table.get('ViewController64.h', traits)).to eq('ViewController64.h')
expect(table.get('ViewController65.h', traits)).to eq('ViewController65.h')
expect(table.get('ViewController66.h', traits)).to eq('ViewController66.h')
expect(table.get('ViewController67.h', traits)).to eq('ViewController67.h')
expect(table.get('ViewController68.h', traits)).to eq('ViewController68.h')
expect(table.get('ViewController69.h', traits)).to eq('ViewController69.h')
expect(table.capacity).to eq(16)
expect(traits.string_table).to eq("\u0000ViewController64.h\u0000ViewController65.h\u0000ViewController66.h\u0000ViewController67.h\u0000ViewController68.h\u0000ViewController69.h\u0000")
```

Store just key string：

```ruby
table = HashTable::HashTable.new
traits = HashTable::StringIdentityHashTraits.new
(0..31).each do |i|
  table.add("ViewController#{i}.h", traits)
end
p "#{table.size}---#{table.capacity}----#{table.num_entries}"
expect(table.size).to eq(32)
expect(table.capacity).to eq(64)
expect(table.num_entries).to eq(32)
```

Store strings and expand capacity:

- num_entries = capacity + 1
- capacity = capacity * 2
- capacity is power_of_two

```ruby
table = HashTable::HashTable.new(1364, expand: true)
traits = HashTable::StringHashTraits.new
buckets = (0..1363).map do |i|
table.set("ViewController#{i}.h",
            ["/Users/ws/Desktop/llvm/TestAndTestApp/TestAndTestApp/Group/h2/#{i}", "ViewController#{i}.h"], traits)
end
p "#{table.size}---#{table.capacity}----#{table.num_entries}"
expect(table.size).to eq(1364)
expect(table.capacity).to eq(8192)
expect(table.num_entries).to eq(4097)
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Cat1237/hashtable. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[Cat1237]/hashtable/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Hashtable project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/Cat1237/hashtable/blob/master/CODE_OF_CONDUCT.md).
