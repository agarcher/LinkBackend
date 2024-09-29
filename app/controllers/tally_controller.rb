class TallyController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :webhook ]

  def webhook
    request_body = request.body.read
    payload = JSON.parse(request_body)

    fields = payload["data"]["fields"]

    name = find_field_value(fields, "Name")
    phone_number = find_field_value(fields, "Phone Number")
    availability = find_availability(fields)
    bio = find_field_value(fields, "Tell us about you")

    user = User.find_or_initialize_by(phone_number: phone_number)
    is_new_user = user.new_record?

    user.update(
      name: name,
      availability: availability,
      bio: bio
    )

    if user.save
      Rails.logger.info("User profile created/updated: #{user.id}")

      # disable welcome messages until demo
      # send_message(user, is_new_user)
    else
      Rails.logger.error("Failed to save user profile: #{user.errors.full_messages}")
    end

    head :ok
  end

  private

  def find_field_value(fields, label)
    field = fields.find { |f| f["label"] == label }
    field ? field["value"] : nil
  end

  def find_availability(fields)
    availability_field = fields.find { |f| f["label"] == "What is your preferred availability?" }
    if availability_field
      selected_option_id = availability_field["value"].first
      selected_option = availability_field["options"].find { |option| option["id"] == selected_option_id }
      selected_option ? selected_option["text"] : nil
    else
      nil
    end
  end

  def send_message(user, is_new_user)
    message_sender = MessageSender.new(user.phone_number)

    if is_new_user
      message = "Welcome to Link! I'm your Link assistant. You'll hear from me weekly to see if you'd like to be connected with someone from the community."
    else
      message = "Thanks for updating your information! We've updated your profile based on your new form submission."
    end

    message_sender.send(message)
  end
end
