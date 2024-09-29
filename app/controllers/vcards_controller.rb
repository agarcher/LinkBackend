class VcardsController < ApplicationController
  def generate
    user_id = params[:user_id]
    user = User.find_by(id: user_id)

    if user
      vcard = create_vcard(user)
      send_vcard(vcard, user)
    else
      render plain: "User not found", status: :not_found
    end
  end

  private

  def create_vcard(user)
    vcard = VCardigan.create
    vcard.name user.name
    vcard.fullname user.name
    vcard.tel user.phone_number if user.phone_number.present?
    vcard
  end

  def send_vcard(vcard, user)
    send_data vcard.to_s,
      type: "text/vcard",
      charset: "utf-8",
      disposition: "attachment",
      filename: "#{user.name.downcase.gsub(/\s+/, '_')}.vcf"
  end
end
