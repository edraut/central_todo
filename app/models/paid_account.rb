class PaidAccount < User

  scope :chargeable, joins("inner join rates on rates.id = users.rate_id").
                     where("users.state = 'in_good_standing' and rates.type != 'FreeRate'")
  scope :bill_today, where(["users.billing_date <= current_date"])
  
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