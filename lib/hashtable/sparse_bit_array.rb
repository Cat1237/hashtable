# frozen_string_literal: true

# module HashTable
module HashTable
  BIT_WORD = 64
  ELEMENT_SIZE = BIT_WORD * 2
  UINT_64_MAX = 2**BIT_WORD - 1
  BITWORD_SIZE = BIT_WORD
  BITWORDS_PER_ELEMENT = (ELEMENT_SIZE + BITWORD_SIZE - 1) / BITWORD_SIZE
  BITS_PER_ELEMENT = ELEMENT_SIZE
  private_constant :BIT_WORD, :ELEMENT_SIZE, :UINT_64_MAX, :BITWORD_SIZE
  private_constant :BITWORDS_PER_ELEMENT, :BITS_PER_ELEMENT, :BITS_PER_ELEMENT
  # SparseBitArrayElement
  # @abstract
  class SparseBitArrayElement
    # @return [Integer] Index of Element in terms of where first bit starts.
    attr_reader :index

    def initialize(index = 0)
      @index = index
      # Index of Element in terms of where first bit starts.
      @bits = Array.new(BITWORDS_PER_ELEMENT, 0)
    end

    # @return [Integer] the bits that make up word index in our element
    # @param  [Integer] index
    def word(index)
      raise ArgumentError, 'index error' unless index < BITWORDS_PER_ELEMENT

      @bits[index]
    end

    def empty?
      (0...BITWORDS_PER_ELEMENT).each do |i|
        return false unless @bits[i].zero?
      end
      true
    end

    def set(index)
      @bits[index / BITWORD_SIZE] |= 1 << (index % BITWORD_SIZE)
    end

    def test?(index)
      @bits[index / BITWORD_SIZE] & (1 << (index % BITWORD_SIZE)) != 0
    end

    def test_and_set?(index)
      unless test(index)
        set(Idx)
        return true
      end
      false
    end

    def reset(index)
      @bits[index / BITWORD_SIZE] &= ~(1 << (index % BITWORD_SIZE))
    end

    # v = @bits[i]
    # v -= ((v >> 1) & 0x5555555555555555)
    # v = (v & 0x3333333333333333) + ((v >> 2) & 0x3333333333333333)
    # v = (v + (v >> 4) & 0x0F0F0F0F0F0F0F0F)
    # v = (v * 0x0101010101010101) & UINT_64_MAX
    # v >>= 56
    def count
      (0...BITWORDS_PER_ELEMENT).inject(0) do |nums, i|
        v = @bits[i].digits(2).count(1)
        nums + v
      end
    end

    # @return [Integer] the index of the first set bit
    def first
      (0...BITWORDS_PER_ELEMENT).each do |i|
        v = @bits[i]
        next if v.zero?

        count = v.digits(2).index(1)
        return i * BITWORD_SIZE + count
      end
    end

    # @return [Integer] the index of the last set bit
    def last
      (0...BITWORDS_PER_ELEMENT).each do |i|
        index = BITWORDS_PER_ELEMENT - i - 1
        v = @bits[index]
        next unless v != 0

        count = BIT_WORD - v.bit_length
        return index * BITWORD_SIZE + BITWORD_SIZE - count - 1
      end
    end

    # @return [Integer] the index of the next set bit starting from the "index" bit.
    # Returns -1 if the next set bit is not found.
    def next(index)
      return -1 if index >= BITS_PER_ELEMENT

      word_pos = index / BITWORD_SIZE
      bit_pos = index % BITWORD_SIZE
      copy = @bits[word_pos]
      raise ArgumentError, 'Word Position outside of element' unless word_pos <= BITS_PER_ELEMENT

      copy &= ~0 << bit_pos
      return word_pos * BITWORD_SIZE + copy.digits(2).index(1) unless copy.zero?

      word_pos += 1
      (word_pos...BITWORDS_PER_ELEMENT).each do |i|
        return i * BITWORD_SIZE + @bits[i].digits(2).index(1) unless @bits[i].zero?
      end
      -1
    end

    include Enumerable

    def each
      return if empty?

      last_i = last
      first_i = first
      bits = 0
      bit_number = 0
      loop do
        while bits.nonzero? && (bits & 1).zero?
          bits >>= 1
          bit_number += 1
        end
        # See if we ran out of Bits in this word.
        if bits.zero?
          next_set_bit_number = self.next(bit_number % ELEMENT_SIZE)
          if next_set_bit_number == -1 || (bit_number % ELEMENT_SIZE).zero?
            next_set_bit_number = first_i
            bit_number = index * ELEMENT_SIZE
            bit_number += next_set_bit_number
            word_number = bit_number % ELEMENT_SIZE / BITWORD_SIZE
            bits = word(word_number)
            bits >>= next_set_bit_number % BITWORD_SIZE
          else
            # Set up for next non-zero word in bitmap
            word_number = next_set_bit_number % ELEMENT_SIZE / BITWORD_SIZE
            bits = word(word_number)
            bits >>= next_set_bit_number % BITWORD_SIZE
            bit_number = index * ELEMENT_SIZE
            bit_number += next_set_bit_number
          end
        end
        yield bit_number
        break if bit_number % ELEMENT_SIZE == last_i

        bit_number += 1
        bits >>= 1
      end
    end
  end

  # SparseBitArray is an implementation of a bitmap that is sparse by only storing the elements that have non-zero bits set.
  # @abstract
  class SparseBitArray
    # @return [Array<SparseBitArrayElement>] The list of Elements
    attr_reader :elements
    # @return [Integer] Pointer to our current Element.
    # This has no visible effect on the external state of a SparseBitArray
    # It's just used to improve performance in the common case of testing/modifying bits with similar indices.
    attr_reader :current_index

    def initialize
      @elements = []
      @current_index = -1
    end

    # @return [Boolean] Test a bit in the bitmap
    # @param [Integer] bit
    def test?(index)
      return false if elements.empty?

      e_index = index / ELEMENT_SIZE
      element_i = lower_bound(e_index)
      last = elements.length
      return false if element_i == last || elements[element_i].index != e_index

      elements[element_i].test?(index % ELEMENT_SIZE)
    end

    # @return [Void] Reset a bit in the bitmap
    # @param [Integer] bit
    def reset(index)
      return if @elements.empty?

      e_index = index / ELEMENT_SIZE
      element_i = lower_bound(e_index)
      element = elements[element_i]
      return if element_i == elements.length || element.index != e_index

      element.reset(index % ELEMENT_SIZE)
      return unless element.empty?

      @elements.delete_at(element_i)
    end

    # @return [Void] Set a bit in the bitmap
    # @param [Integer] bit
    def set(index)
      e_index = index / ELEMENT_SIZE
      element_i = lower_bound(e_index)
      new_e = elements[element_i]
      unless new_e.nil?
        element_i += 1 if new_e.index < e_index
        new_e = nil if new_e.index != e_index
      end
      @current_index = element_i
      @elements.insert(@current_index, SparseBitArrayElement.new(e_index)) if new_e.nil?
      @elements[@current_index].set(index % ELEMENT_SIZE)
    end

    # @return [Void] Test, Set a bit in the bitmap
    # @param [Integer] bit
    def test_and_set?(index)
      unless test?(index)
        set(Idx)
        return true
      end
      false
    end

    def count
      @elements.inject(0) { |c, e| c + e.count }
    end

    def clear
      @elements.clear
    end

    # @return [Integer] the first set bit in the bitmap.
    # Return -1 if no bits are set.
    def first
      return -1 if elements.empty?

      first = elements.first
      first.index * ELEMENT_SIZE + first.first
    end

    # @return [Integer] the last set bit in the bitmap.
    # Return -1 if no bits are set.
    def last
      return -1 if elements.empty?

      last = elements.last
      last.index * ELEMENT_SIZE + last.last
    end

    def empty?
      elements.empty?
    end

    include Enumerable

    def each(&block)
      @elements.each { |element| element.each(&block) }
    end

    private

    # @return [Integer] do linear searching from the current position.
    def lower_bound(index)
      return 0 if elements.empty?

      @current_index -= 1 if @current_index == elements.length
      element_i = @current_index
      element = @elements[element_i]
      return element_i if element.index == index

      @current_index = if element.index > index
                         @elements[0..element_i].rindex { |e| e.index <= index } || 0
                       else
                         @elements[element_i..].select { |e| e.index < index }.length + element_i
                       end
    end
  end
end
