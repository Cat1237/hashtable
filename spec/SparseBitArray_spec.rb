require 'benchmark'

RSpec.describe do
  it 'SparseBitArrayElement' do
    e = HashTable::SparseBitArrayElement.new
    e.set(23)
    e.set(56)
    expect(e.test?(23)).to eq(true)
    expect(e.test?(56)).to eq(true)
    expect(e.test?(22)).to eq(false)
  end

  it 'SparseBitArrayElement Enumerator' do
    e = HashTable::SparseBitArrayElement.new
    e.set(23)
    e.set(24)
    e.set(25)
    e.set(56)
    e.set(125)
    e.each do |index|
      p index
    end
  end

  it 'SparseBitArray Enumerator' do
    e = HashTable::SparseBitArray.new
    Benchmark.bm(7) do |x|
      x.report("each:") do
        (0..2263).to_a.each_index do |i|
          e.set(i)
          e.test?(i)
          e.reset(i)
        end
      end
    end
  end

  it 'SparseBitArray' do
    e = HashTable::SparseBitArray.new
    expect(e.count).to eq(0)
    expect(e.test?(17)).to eq(false)
    e.set(5)
    expect(e.test?(5)).to eq(true)
    expect(e.test?(17)).to eq(false)
    e.reset(6)
    expect(e.test?(5)).to eq(true)
    expect(e.test?(6)).to eq(false)
    e.reset(5)
    expect(e.test?(5)).to eq(false)
    e.clear
    expect(e.test?(17)).to eq(false)

    e.set(1337)
    expect(e.test?(1337)).to eq(true)
    e.set(1337)
    expect(e.test?(1337)).to eq(true)
    expect(e.empty?).to eq(false)
  end

  it 'SparseBitArray find' do
    e = HashTable::SparseBitArray.new
    e.set(1)
    expect(e.first).to eq(1)
    expect(e.last).to eq(1)

    e.set(2)
    expect(e.first).to eq(1)
    expect(e.last).to eq(2)

    e.set(0)
    e.set(3)
    expect(e.first).to eq(0)
    expect(e.last).to eq(3)

    e.reset(1)
    e.reset(0)
    e.reset(3)
    expect(e.first).to eq(2)
    expect(e.last).to eq(2)

    e.set(500)
    expect(e.test?(500)).to eq(true)
    e.set(2000)
    e.set(3000)
    e.set(4000)
    e.reset(2)
    expect(e.count).to eq(4)
    expect(e.first).to eq(500)
    expect(e.last).to eq(4000)

    e.reset(500)
    e.reset(3000)
    e.reset(4000)
    expect(e.first).to eq(2000)
    expect(e.last).to eq(2000)
  end
end
