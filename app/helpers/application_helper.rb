module ApplicationHelper
  def truncate_clean(string,options_hash)
    return '' unless string.class.name == 'String'
    omission = options_hash[:omission]
    omission ||= ''
    if options_hash.has_key? :max_word_length and options_hash[:max_word_length]
      bstring = BreakableString.new
      bstring.string = string[0..options_hash[:length]]
      bstring.add_word_breaks(options_hash[:max_word_length])
      string = bstring.string
    end
    if options_hash[:length] >= string.length
      return string
    elsif string[options_hash[:length]] =~ /\s/ or options_hash[:exact_length]
      return string[0..options_hash[:length]] + omission
    else
      truncation = string[0..(options_hash[:length] - 1)]
      truncation.chop! until truncation[-1].chr =~ /\s/
      return truncation + omission
    end
  end
  
  def to_str_list(array)
    if array.length > 1
      list = array.join(', ')
      list.insert(-(list.reverse.index(',')),'and ')
      return list
    else
      return array.first.to_s
    end
  end
end
