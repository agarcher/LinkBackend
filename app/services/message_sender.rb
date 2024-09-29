class MessageSender
  def initialize(phone_number)
    @phone_number = phone_number
  end

  def send_message(message, media_urls = [])
    client = Twilio::REST::Client.new(ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"])

    from = ENV["TWILIO_PHONE_NUMBER"]
    to = @phone_number

    # exclude numbers that have not been verified on twilio
    invalid_numbers = ["+16478543425", "+17708801136", "+14159107172", "+16479145611"]
    if (invalid_numbers.include?(@phone_number))
      return
    end

    # valid_numbers = ["+14164276719", "+16478973143", "+16472018395", "+16476776878"]
    # if (!valid_numbers.include?(@phone_number))
    #   return
    # end

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
