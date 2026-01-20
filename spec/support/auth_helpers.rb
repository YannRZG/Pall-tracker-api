module AuthHelpers
  def login(user)
    post "/login", params: {
      user: {
        email: user.email,
        password: "password"
      }
    }
  end

  def json
    JSON.parse(response.body)
  end
end
