defmodule ExBackendWeb.SessionView do
  use ExBackendWeb, :view

  def render("info.json", %{info: token, user: user}) do
    %{
      access_token: token,
      user: %{
        id: user.id,
        email: user.email,
        roles: user.roles
      }
    }
  end
end
