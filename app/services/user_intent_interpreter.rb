class UserIntentInterpreter
  BASE_URL = "https://api.openai.com/v1/chat/completions"
  MODEL = "gpt-4o-mini"

  def initialize
    @api_key = ENV["OPENAI_API_KEY"]
  end

  def interpret_intent(user_response)
    system_prompt = "Your job is to help me interpret the intent of a user. I have asked the user 'Do you want to link up with someone new this week?'

Your job is to tell me if they are in or not. You can only respond with exactly one of the following values: yes, no, maybe

Please don't give any details or justification. Just a one word response.

Only respond maybe if they actually gave an answer like maybe. If they say yes with a low-enthusiasm response like 'alright', 'sure', 'okay', etc. interpret that as a yes."

    uri = URI(BASE_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request["Authorization"] = "Bearer #{@api_key}"

    request.body = {
      model: MODEL,
      messages: [
        { role: "system", content: system_prompt },
        { role: "user", content: user_response }
      ],
      temperature: 0.4
    }.to_json

    response = http.request(request)

    if response.is_a?(Net::HTTPSuccess)
      intent = JSON.parse(response.body)["choices"][0]["message"]["content"].downcase
      if intent == "yes" || intent == "no"
        intent
      else
        "maybe"
      end
    else
      raise "OpenAI API request failed with status #{response.code}: #{response.body}"
    end
  end
end
