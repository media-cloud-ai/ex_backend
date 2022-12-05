defmodule ExBackendWeb.CredentialController do
  use ExBackendWeb, :controller
  use OpenApiSpex.ControllerSpecs

  import ExBackendWeb.Authorize

  alias ExBackend.Credentials
  alias ExBackend.Credentials.Credential
  alias ExBackendWeb.OpenApiSchemas

  tags ["Credentials"]
  security [%{"authorization" => %OpenApiSpex.SecurityScheme{type: "http", scheme: "bearer"}}]

  action_fallback(ExBackendWeb.FallbackController)

  # the following plugs are defined in the controllers/authorize.ex file
  plug(:user_check when action in [:index, :show, :delete, :update])
  plug(:right_administrator_check when action in [:index, :show, :delete, :update])

  operation :index,
    summary: "List all credentials",
    description: "Retrieve all credentials",
    type: :object,
    responses: [
      ok: {"Credentials", "application/json", OpenApiSchemas.Credentials.Credentials},
      forbidden: "Forbidden"
    ]

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

  operation :create,
    summary: "Create credential",
    description: "Create credential",
    type: :object,
    request_body:
      {"Credential Body", "application/json", OpenApiSchemas.Credentials.CredentialBody},
    responses: [
      ok: {"Credential", "application/json", OpenApiSchemas.Credentials.Credential},
      forbidden: "Forbidden"
    ]

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

  operation :update,
    summary: "Edit credential",
    description: "Edit credential",
    type: :object,
    request_body:
      {"Credential Body", "application/json", OpenApiSchemas.Credentials.CredentialBody},
    responses: [
      ok: {"Credential", "application/json", OpenApiSchemas.Credentials.Credential},
      forbidden: "Forbidden"
    ]

  def update(conn, %{"id" => identifier, "credential" => credential_params}) do
    credential = Credentials.get_credential!(identifier)

    case Credentials.update_credential(credential, credential_params) do
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

  operation :show,
    summary: "Get credential",
    description: "Get a credential by id or key",
    type: :object,
    parameters: [
      id: [
        in: :path,
        description: "Credential ID or key",
        type: :integer,
        example: 1
      ]
    ],
    responses: [
      ok: {"Credential", "application/json", OpenApiSchemas.Credentials.Credential},
      forbidden: "Forbidden",
      not_found: "Not Found"
    ]

  def show(conn, %{"id" => identifier}) do
    case Integer.parse(identifier) do
      {id, ""} -> get_by_id(conn, %{"id" => id})
      _ -> get_by_key(conn, %{"id" => identifier})
    end
  end

  def get_by_key(conn, %{"id" => key}) do
    credential = Credentials.get_credential_by_key!(key)
    render(conn, "show.json", credential: credential)
  end

  def get_by_id(conn, %{"id" => id}) do
    credential = Credentials.get_credential!(id)
    render(conn, "show.json", credential: credential)
  end

  operation :delete,
    summary: "Delete credential",
    description: "Delete credential by id or key",
    type: :object,
    parameters: [
      id: [
        in: :path,
        description: "Credential ID or key",
        type: :integer,
        example: 1
      ]
    ],
    responses: [
      no_content: "No Content",
      forbidden: "Forbidden",
      not_found: "Not Found"
    ]

  def delete(conn, %{"id" => id}) do
    credential = Credentials.get_credential!(id)

    with {:ok, %Credential{}} <- Credentials.delete_credential(credential) do
      send_resp(conn, :no_content, "")
    end
  end

  operation :update, false
end
