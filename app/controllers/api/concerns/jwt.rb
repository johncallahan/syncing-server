module Api::Concerns::Jwt
  require 'jwt'

  def jwt_encode(payload)
    JWT.encode(payload, secret_key_base, 'HS256')
  end

  def jwt_decode(token)
    decoded_token = JWT.decode(token, secret_key_base, true, algorithm: 'HS256')[0]
    HashWithIndifferentAccess.new(decoded_token)
  rescue StandardError => e
    puts e
    nil
  end

  extend self

  def secret_key_base
    Rails.application.secrets.secret_key_base
  end
end
