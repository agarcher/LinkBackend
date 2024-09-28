class MessageSender
  def initialize(phone_number)
    @phone_number = phone_number
  end

  def send(message)
    client = Twilio::REST::Client.new(ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"])

    from = ENV["TWILIO_PHONE_NUMBER"]
    to = @phone_number

    client.messages.create(
      from: from,
      to: to,
      body: message
    )
  end
end
