class PaidAccount < User
  
  def handle_validity
    if self.card_valid?
      unless self.in_good_standing?
        self.activate_account
      end
    else
      if self.in_good_standing?
        self.hold_account
      end
    end
  end
end