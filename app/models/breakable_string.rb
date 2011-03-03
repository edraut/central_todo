class BreakableString
  attr_accessor :string
  def word_break_offset(max_word_length)
    words = self.string.split(/[\s]+/)
    long_word = words.detect{|w| w.length > max_word_length}
    if long_word
      long_word_end = self.string.index(long_word) + max_word_length
      return long_word_end
    else
      return false
    end
  end
  def add_word_breaks(max_word_length)
    this_offset = self.word_break_offset(max_word_length)
    while this_offset
      self.string.insert(this_offset - 1,"-\n")
      this_offset = self.word_break_offset(max_word_length)
    end
  end
end
