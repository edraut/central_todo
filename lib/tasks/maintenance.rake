namespace :maintenance do
  task :send_reminders => :environment do
    Reminder.today.each do |reminder|
      if (Time.now.in_time_zone(reminder.user.time_zone).hour - 8) == reminder.id % 8
        begin
          case reminder.class.name
          when 'SmsReminder'
            Notifier.remind_sms(reminder).deliver
          when 'EmailReminder'
          end
          reminder.complete
          reminder.save
        rescue
          Rails.logger.error "Error sending mail via gmail SMTP servers:"
          Rails.logger.error $!
          Rails.logger.error $!.backtrace
          Rails.logger.error "End error sending mail via gmail SMTP servers."
          reminder.attempt
          reminder.save
        end
      end
    end
    Rails.logger.flush
  end
  task :charge_cards => :environment do
    gateway = ActiveMerchant::Billing::AuthorizeNetCimGateway.new( :login => AUTH_NET_LOGIN, :password => AUTH_NET_TRANS_ID )
    PaidAccount.chargeable.bill_today.each do |u|
      user = User.find(u.id)
      response = gateway.create_customer_profile_transaction(
        :transaction => {
          :type => :auth_capture,
          :amount => user.rate.amount,
          :customer_profile_id => user.cim_id,
          :customer_payment_profile_id => user.cim_payment_profile_id,
          :order => {
            :invoice_number => "U#{user.id}R#{user.rate.id}D#{Date.today.to_s}",
            :description => "#{user.email} billing period ending: #{user.billing_date.to_formatted_s(:full)}"
          }
        }
      )
      if response.message == 'Successful.'
        user.billing_date = user.billing_date + 1.send(user.rate.frequency)
        user.charge_attempts = 0
        user.save
        Notifier.billing_statement(user).deliver
      else
        user.charge_attempts += 1
        user.charge_failure_reason = response.message
        if user.charge_attempts == 5
          user.card_valid = false
          user.save
          Notifier.account_deactivated(user).deliver
        else
          Notifier.card_warning(user).deliver
        end
      end
    end
  end
end