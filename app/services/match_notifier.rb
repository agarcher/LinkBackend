class MatchNotifier
  def self.notify_match(user_match)
    media_urls = [
      Rails.application.routes.url_helpers.generate_vcard_url(user_id: user_match.matched_user_id, host: "https://#{ENV['HOSTNAME']}"),
    ]

    MessageSender.new(user_match.user.phone_number).send_message(user_match.match_message, media_urls)
  end
end
