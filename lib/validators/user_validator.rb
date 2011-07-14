class UserValidator < ActiveModel::Validator
  def validate(record)
    if !record.no_tos && !record.tos_agreed?
      record.errors[:tos_agreed] << "You must accept the Terms of Service."
    end
  end
end
