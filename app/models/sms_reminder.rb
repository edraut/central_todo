class SmsReminder < Reminder
  SMS_GATEWAYS = {'AT&T' => '@txt.att.net','Verizon' => '@vtext.com','T-Mobile' => '@tmomail.net','Sprint' => '@messaging.sprintpcs.com','Cricket' => '@sms.mycricket.com'}
  def self.display_name
    'SMS'
  end
end