defmodule ExSubtilBackendWeb.ConfirmView do
  use ExSubtilBackendWeb, :view

  def render("info.json", %{info: message}) do
    %{info: %{detail: message}}
  end
end
