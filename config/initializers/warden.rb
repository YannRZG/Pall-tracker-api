Warden::JWTAuth.configure do |config|
  config.secret = ENV["JWT_SECRET_KEY"]
end
