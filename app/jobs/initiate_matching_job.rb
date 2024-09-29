class InitiateMatchingJob < ApplicationJob
  queue_as :default

  def perform
    ActiveRecord::Base.transaction do
      # Fetch the latest UserMatch record for each user_id and preload the associated users
      latest_matches = UserMatch.select('DISTINCT ON (user_id) *')
                                .order('user_id, id DESC')
                                .includes(:user)

      # Process the matches
      match_data = []
      latest_matches.each do |user_match|
        if (user_match.opt_in_result.nil?)
          # TODO notify the user that we are starting matching and they are being opted out automatically?
          user_match.opt_in_result = false
        end
        user_match.matching_started = true
        user_match.save!

        next if (!user_match.opt_in_result?)

        match_data << {
          "Name" => user_match.user.name,
          "Phone" => user_match.user.phone_number,
          "Bio" => user_match.user.bio,
          "Availability" => user_match.user.availability,
          "Response" => user_match.topic_response,
        }
      end

      # Log the match data
      Rails.logger.info("Initiating matching for #{match_data.length} users")
      Rails.logger.info("Match data: #{match_data}")
    end
  end
end
