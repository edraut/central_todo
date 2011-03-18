namespace :maintenance do
  task :send_reminders => :environment do
    Reminder.next_minute.each do |reminder|
      begin
        case reminder.class.name
        when 'SmsReminder'
          Notifier.remind_sms(reminder).deliver
        when 'EmailReminder'
          Notifier.remind(reminder).deliver
        end
        reminder.complete
        Rails.logger.info("%%%%%%%beforesave: #{reminder.inspect}")
        reminder.save
        Rails.logger.info("%%%%%%%aftersave: #{reminder.inspect}")
      rescue
        Rails.logger.error "Error sending mail via gmail SMTP servers:"
        Rails.logger.error $!
        Rails.logger.error $!.backtrace
        Rails.logger.error "End error sending mail via gmail SMTP servers."
        reminder.attempt
        reminder.save
      end
    end
    Rails.logger.flush
  end
end