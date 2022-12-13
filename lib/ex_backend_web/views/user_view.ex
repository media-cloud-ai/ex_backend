defmodule ExBackendWeb.UserView do
  use ExBackendWeb, :view
  alias ExBackendWeb.UserView

  def render("index.json", %{users: %{data: users, total: total}}) do
    %{
      data: render_many(users, UserView, "user.json"),
      total: total
    }
  end

  def render("show.json", %{user: user, credentials: credentials}) do
    if credentials do
      %{data: render_one(user, UserView, "credentials.json")}
    else
      %{data: render_one(user, UserView, "user.json")}
    end
  end

  def render("info.json", %{info: message}) do
    %{info: %{detail: message}}
  end

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      email: user.email,
      roles: user.roles,
      confirmed_at: user.confirmed_at,
      inserted_at: user.inserted_at,
      uuid: user.uuid,
      access_key_id: user.access_key_id,
      first_name: user.first_name,
      last_name: user.last_name,
      username: user.username
    }
  end

  def render("credentials.json", %{user: user}) do
    %{
      id: user.id,
      email: user.email,
      roles: user.roles,
      confirmed_at: user.confirmed_at,
      inserted_at: user.inserted_at,
      uuid: user.uuid,
      access_key_id: user.access_key_id,
      secret_access_key: user.secret_access_key,
      first_name: user.first_name,
      last_name: user.last_name,
      username: user.username
    }
  end
end
