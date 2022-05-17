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
    @string_table[offset..-1][/[^\0]+/]
  end
end

RSpec.describe Hashtable do
  it 'hash table' do
    table = HashTable::HashTable.new(2)
    table.set(3, 7, Traits.new)
    table.set(4, 5, Traits.new)
    table.set(5, 6, Traits.new)
    table.set(6, 7, Traits.new)
    table.set(8, 9, Traits.new)
    table.set(9, 19, Traits.new)
    expect(table.size).to eq(6)
    expect(table.get(3, Traits.new)).to eq(7)
    expect(table.get(4, Traits.new)).to eq(5)
    expect(table.get(5, Traits.new)).to eq(6)
    expect(table.get(6, Traits.new)).to eq(7)
    expect(table.get(8, Traits.new)).to eq(9)
    expect(table.get(9, Traits.new)).to eq(19)
    expect(table.capacity).to eq(16)
  end

  it 'hash string table' do
    table = HashTable::HashTable.new(2)
    traits = StringTraits.new
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
  end

  it 'hash string table add' do
    table = HashTable::HashTable.new
    traits = StringTraits.new
    (0..31).each do |i|
      table.add("ViewController#{i}.h", traits)
    end
    p "#{table.size}---#{table.capacity}----#{table.num_entries}"
    expect(table.size).to eq(32)
    expect(table.capacity).to eq(64)
    expect(table.num_entries).to eq(32)
  end

  it 'hash string table 86 expand add' do
    table = HashTable::HashTable.new(expand: true)
    traits = StringTraits.new
    (0..85).each do |i|
      table.add("ViewController#{i}.h", traits)
    end
    p "#{table.size}---#{table.capacity}----#{table.num_entries}"
    expect(table.size).to eq(86)
    expect(table.capacity).to eq(512)
    expect(table.num_entries).to eq(257)
  end

  it 'hash string table 341 expand add' do
    table = HashTable::HashTable.new(expand: true)
    traits = StringTraits.new
    (0..340).each do |i|
      table.add("ViewController#{i}.h", traits)
    end
    p "#{table.size}---#{table.capacity}----#{table.num_entries}"
    expect(table.size).to eq(341)
    expect(table.capacity).to eq(2048)
    expect(table.num_entries).to eq(1025)
  end

  it 'hash string table 1364 6expand add' do
    table = HashTable::HashTable.new(8192, expand: true)
    traits = StringTraits.new
    (0..1363).each do |i|
      table.add("ViewController#{i}.h", traits)
    end
    p "#{table.size}---#{table.capacity}----#{table.num_entries}"
    expect(table.size).to eq(1364)
    expect(table.capacity).to eq(8192)
    expect(table.num_entries).to eq(4097)
  end

  it 'hash string table expand adds' do
    table = HashTable::HashTable.new(expand: true)
    traits = StringTraits.new
    bucket = table.adds(%w[TestAndTestApp/ViewController.h
                  /Users/ws/Desktop/llvm/TestAndTestApp/TestAndTestApp/Group/h2/
                  ViewController.h], traits)
    p "#{table.size}---#{table.capacity}----#{table.num_entries}"
    expect(table.size).to eq(3)
    expect(table.capacity).to eq(8)
    expect(table.num_entries).to eq(3)
    expect(traits.string_table).to eq("\u0000TestAndTestApp/ViewController.h\u0000/Users/ws/Desktop/llvm/TestAndTestApp/TestAndTestApp/Group/h2/\u0000ViewController.h\u0000")
    expect(bucket).to eq([1, 33, 96])
  end

  it 'hash string table expand adds' do
    table = HashTable::HashTable.new(8192, expand: true)
    traits = StringTraits.new
    buckets = (0..1363).map do |i|
      a = ["ViewController#{i}.h", "/Users/ws/Desktop/llvm/TestAndTestApp/TestAndTestApp/Group/h2/#{i}", "ViewController#{i}.h"]
      table.adds(a, traits)
    end
    p "#{table.size}---#{table.capacity}----#{table.num_entries}"
    expect(table.size).to eq(2728)
    expect(table.capacity).to eq(8192)
    expect(table.num_entries).to eq(5461)
  end
end
