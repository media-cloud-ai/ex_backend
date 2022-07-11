defmodule ExBackendWeb.CredentialController do
  use ExBackendWeb, :controller

  import ExBackendWeb.Authorize

  alias ExBackend.Credentials
  alias ExBackend.Credentials.Credential

  action_fallback(ExBackendWeb.FallbackController)

  # the following plugs are defined in the controllers/authorize.ex file
  plug(:user_check when action in [:index, :show, :delete])
  plug(:right_administrator_check when action in [:index, :show, :delete])

  api :GET, "/api/credentials" do
    title("List all Credentials")
    description("Retrieve all credentials")

    parameter(:page, :integer, optional: true, description: "Index of the page")
    parameter(:size, :integer, optional: true, description: "Size per page")
    parameter(:key, :string, description: "Search by key")
  end

  def index(conn, params) do
    # local_token = "mediacloudai"

    # vault =
    #   Vault.new(
    #     engine: Vault.Engine.KVV2,
    #     auth: Vault.Auth.Token,
    #     host: "http://192.168.99.101:8201",
    #     token: local_token
    #   )

    # Vault.list(vault, "secret/")

    credentials = Credentials.list_credentials(params)
    render(conn, "index.json", credentials: credentials)
  end

  def create(conn, credential_params) do
    case Credentials.create_credential(credential_params) do
      {:ok, %Credential{} = credential} ->
        conn
        |> put_status(:created)
        |> render("show.json", credential: credential)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(ExBackendWeb.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    credential = Credentials.get_credential_by_key!(id)
    render(conn, "show.json", credential: credential)
  end

  def delete(conn, %{"id" => id}) do
    credential = Credentials.get_credential!(id)

    with {:ok, %Credential{}} <- Credentials.delete_credential(credential) do
      send_resp(conn, :no_content, "")
    end
  end
end
