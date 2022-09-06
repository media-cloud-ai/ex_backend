defmodule ExBackendWeb.SessionView do
  use ExBackendWeb, :view

  def render("info.json", %{info: token, user: user}) do
    %{
      access_token: token,
      user: %{
        id: user.id,
        first_name: user.first_name,
        last_name: user.last_name,
        username: user.username,
        email: user.email,
        roles: user.roles
      }
    }
  end
end
