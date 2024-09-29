class MatchNotifier
  def self.notify_match(user_match)
    notify_users(user_match.user, user_match.matched_user)
  end

  def self.notify_users(user, matched_user)
    message = "Great news! We've matched you with #{matched_user.first_name}. Reach out to find a time to meet this week.

You'll be heading to Isle of Coffee. Grab a drink, and explore the area together!

https://maps.app.goo.gl/mKu1Ji9mX8CMdjKv5"
    media_urls = [
      Rails.application.routes.url_helpers.generate_vcard_url(user_id: matched_user.id, host: "https://#{ENV['HOSTNAME']}"),
    ]

    MessageSender.new(user.phone_number).send_message(message, media_urls)
  end
end
