class TwilioController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :webhook ]

  before_action :authenticate_twilio_webhook, only: [ :webhook ]

  def webhook
    from_number = params["From"]
    message_body = params["Body"]

    Rails.logger.info("Received SMS from #{from_number}: #{message_body}")

    head :ok
  end

  private

  def authenticate_twilio_webhook
    Rails.logger.info("Authenticating Twilio webhook")
    auth_token = ENV["TWILIO_AUTH_TOKEN"]

    # Initialize the request validator
    validator = Twilio::Security::RequestValidator.new(auth_token)

    # Store Twilio's request URL (the url of your webhook) as a variable
    url = "https://#{request.host}/twilio/webhook"

    # Store the application/x-www-form-urlencoded params from Twilio's request as a variable
    # In practice, this MUST include all received parameters, not a
    # hardcoded list of parameters that you receive today. New parameters
    # may be added without notice.
    twilio_params = params.to_unsafe_h.symbolize_keys.except(:controller, :action)
    Rails.logger.info(twilio_params)

    # Store the X-Twilio-Signature header attached to the request as a variable
    twilio_signature = request.headers["X-Twilio-Signature"]
    Rails.logger.info("Twilio signature: #{twilio_signature}")

    # Check if the incoming signature is valid for your application URL and the incoming parameters
    result = validator.validate(url, twilio_params, twilio_signature)
    Rails.logger.info("Authentication result: #{result}")
  end
end
