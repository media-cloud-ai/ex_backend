defmodule ExBackendWeb.ConfirmView do
  use ExBackendWeb, :view

  def render("info.json", %{info: message}) do
    %{info: %{detail: message}}
  end
end
