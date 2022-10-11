defmodule ExBackendWeb.PasswordResetView do
  use ExBackendWeb, :view

  def render("info.json", %{info: message}) do
    %{detail: message}
  end

  def render("error.json", %{error: message}) do
    %{custom_error_message: message}
  end
end
