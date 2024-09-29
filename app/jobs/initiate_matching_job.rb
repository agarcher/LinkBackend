class InitiateMatchingJob < ApplicationJob
  queue_as :default

  def perform
    match_data = prepare_match_data
    if match_data.any?
      match_results = send_match_request(match_data)
      process_match_results(match_results)
    else
      Rails.logger.info("No users to match at this time.")
    end
  end

  private

  def prepare_match_data
    match_data = []
    ActiveRecord::Base.transaction do
      latest_matches = UserMatch.select('DISTINCT ON (user_id) *')
                                .order('user_id, id DESC')
                                .includes(:user)

      latest_matches.each do |user_match|
        if user_match.opt_in_result.nil?
          user_match.opt_in_result = false
          # TODO: Notify the user that they are being opted out automatically
        end
        user_match.matching_started = true
        user_match.save!

        next unless user_match.opt_in_result?

        match_data << {
          "Name" => user_match.user.name,
          "Phone" => user_match.user.phone_number,
          "Bio" => user_match.user.bio,
          "Availability" => user_match.user.availability,
          "Response" => user_match.topic_response,
        }
      end
    end

    Rails.logger.info("Initiating matching for #{match_data.length} users")
    Rails.logger.info("Match data: #{match_data}")
    match_data
  end

  def send_match_request(match_data)
    uri = URI.parse(ENV['MATCH_SERVICE_URL'])
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'

    request = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
    request.body = match_data.to_json

    response = http.request(request)

    if response.is_a?(Net::HTTPSuccess)
      JSON.parse(response.body)
    else
      Rails.logger.error("Failed to get match results: #{response.code} - #{response.message}")
      []
    end
  end

  def process_match_results(match_results)
    Rails.logger.info("Processing match results: #{match_results}")
    if match_results.any?
      MatchResultProcessor.process(match_results)
      Rails.logger.info("Match results processed successfully")
    else
      Rails.logger.warn("No match results received from the matching service")
    end
  end
end
