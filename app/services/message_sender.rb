class MessageSender
  def initialize(phone_number)
    @phone_number = phone_number
  end

  def send_message(message, media_urls = [])
    client = Twilio::REST::Client.new(ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"])

    from = ENV["TWILIO_PHONE_NUMBER"]
    to = @phone_number

    # Only message me while testing and debugging
    if (@phone_number != "+14164276719")
      return
    end

    # Call create with named arguments using double splat operator
    if (media_urls.any?)
      client.messages.create(
        from: from,
        to: to,
        body: message,
        media_url: media_urls
      )
    else
      client.messages.create(
        from: from,
        to: to,
        body: message
      )
    end
  end
end
