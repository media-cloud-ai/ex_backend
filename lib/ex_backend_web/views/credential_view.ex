defmodule ExBackendWeb.CredentialView do
  use ExBackendWeb, :view
  alias ExBackendWeb.CredentialView

  def render("index.json", %{credentials: %{data: credentials, total: total}}) do
    %{
      data: render_many(credentials, CredentialView, "credential.json"),
      total: total
    }
  end

  def render("show.json", %{credential: credential}) do
    %{data: render_one(credential, CredentialView, "credential.json")}
  end

  def render("credential.json", %{credential: credential}) do
    %{
      id: credential.id,
      key: credential.key,
      value: credential.value,
      inserted_at: credential.inserted_at
    }
  end
end
