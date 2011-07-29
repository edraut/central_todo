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
end