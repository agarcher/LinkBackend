class TwilioController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :webhook ]

  before_action :authenticate_twilio_webhook, only: [ :webhook ]

  def webhook
    from_number = params["From"]
    message_body = params["Body"]

    user = User.find_by(phone_number: from_number)
    if user.nil?
      Rails.logger.warn("Ignoring SMS received from unknown number: #{from_number}")
      head :ok
      return
    end

    last_match = user.user_matches.last

    if last_match.nil? || last_match.opt_in_result == false || last_match.topic_response.present? || last_match.matching_started?
      Rails.logger.warn("Ignoring SMS received from #{from_number}: #{message_body} because we are not expecting a response from #{user.name} right now")
      head :ok
      return
    end

    Rails.logger.info("Processing SMS received from #{from_number}: #{message_body}")

    last_match.transaction do
      sms_response = if last_match.opt_in_result.nil?
        handle_opt_in_message(last_match, message_body)
      else
        handle_topic_message(last_match, message_body)
      end

      MessageSender.new(user.phone_number).send_message(sms_response)
    end

    head :ok
  end

  private

  def handle_opt_in_message(last_match, message_body)
    intent = UserIntentInterpreter.new.interpret_intent(message_body)
    if intent == "yes"
      last_match.update({ opt_in_result: true, opt_in_response: message_body, topic_sms_sent: Time.now })
      "You're in! To help find the perfect match, let me know what's on your mind right now, what's going on with you, or what you'd like to talk about."
    elsif intent == "no"
      last_match.update({ opt_in_result: false, opt_in_response: message_body })
      "You're out. No worries, I'll check back next week."
    else
      "Sorry, I didn't understand that. Are you in?"
    end
  end

  def handle_topic_message(last_match, message_body)
    last_match.update({ topic_response: message_body })
    "Thanks for the update. I'll find you someone amazing."
  end

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
