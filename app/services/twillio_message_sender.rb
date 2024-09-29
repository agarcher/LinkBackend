class MessageSender
  def initialize(phone_number)
    @phone_number = phone_number
  end

  def send_message(message, media_urls = [])
    client = Twilio::REST::Client.new(ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"])

    from = ENV["TWILIO_PHONE_NUMBER"]
    to = @phone_number

    message_params = {
      from: from,
      to: to,
      body: message
    }

    message_params[:media_url] = media_urls if media_urls.any?

    client.messages.create(**message_params)
  end
end
