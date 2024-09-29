class MatchResultProcessor
  def self.process(match_results)
    new(match_results).process
  end

  def initialize(match_results)
    @match_results = match_results
  end

  def process
    @match_results.each do |match|
      process_match(match)
    end
  end

  private

  def process_match(match)
    phone_numbers = match.keys - ['cafeinfo']
    cafe_info = match['cafeinfo']

    phone_numbers.combination(2).each do |phone1, phone2|
      user1 = User.find_by(phone_number: phone1)
      user2 = User.find_by(phone_number: phone2)  
      update_user_match(user1, user2, match[phone1], cafe_info)
      update_user_match(user2, user1, match[phone2], cafe_info)
    end
  end

  def update_user_match(user, matched_user, message, cafe_info)
    user_match = UserMatch.where(user_id: user.id).order(created_at: :desc).first

    if user_match
      user_match.update!(
        matched_user: matched_user,
        match_message: "#{message}\n\n#{cafe_info}",
        matching_completed: true,
      )
      MatchNotifier.notify_match(user_match)
    else
      Rails.logger.error("UserMatch not found for phone number: #{user.phone_number}")
    end
  rescue => e
    Rails.logger.error("Error updating UserMatch for phone number: #{user.phone_number}: #{e.message}")
  end
end