class CaseInsensitiveniquenessValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless (record.new_record? and record.class.find(:first, :conditions => ["lower(#{attribute}) = :attribute",{:attribute => value.downcase}])) or
      (!record.new_record? and User.find(:first, :conditions => ["lower(#{attribute}) = :attribute and id != :id",{:id => record.id, :attribute => value.downcase}]))
      record.errors[attribute] << (options[:message] || "is already in use, please try another.")
    end
  end
end