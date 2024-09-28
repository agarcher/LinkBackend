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

    Rails.logger.info("Tally Form Submission:")
    Rails.logger.info("Name: #{name}")
    Rails.logger.info("Phone Number: #{phone_number}")
    Rails.logger.info("Preferred Availability: #{availability}")
    Rails.logger.info("Bio: #{bio}")

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
end
