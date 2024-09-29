class InitiateMatchingJob < ApplicationJob
  queue_as :default

  def perform
    success_count = 0
    User.find_each do |user|
      begin
        ActiveRecord::Base.transaction do
          UserMatch.create!(user: user, opt_in_sms_sent: Time.current)

          first_name = user.name.split(" ").first
          message = "Hi #{first_name}! Do you want to link up with someone new this week?"
          MessageSender.new(user.phone_number).send(message)
        end

        success_count += 1
      rescue StandardError => e
        Rails.logger.error("Skipping #{user.name} (#{user.id}) because matching failed: #{e.message}")
      end
    end

    Rails.logger.info("Initiated matching for #{success_count} users")
  end
end
