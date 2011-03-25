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
  
  def hour_select_options_array
    (0..23).to_a.map do |h|
      hour = case h
      when 0
        12
      when (13..23)
        h - 12
      else
        h
      end
      ampm = (h > 11) ? 'PM' : 'AM'
      [hour.to_s + ' ' + ampm,h]
    end
  end
  def mobile_device_type
    return 'ios' if request.user_agent.to_s.downcase =~ Regexp.new('ipad|iphone')
    return 'non-ios'
  end
  
end
