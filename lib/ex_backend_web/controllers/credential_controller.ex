defmodule ExBackendWeb.CredentialController do
  use ExBackendWeb, :controller
  use PhoenixSwagger

  import ExBackendWeb.Authorize

  alias ExBackend.Credentials
  alias ExBackend.Credentials.Credential

  action_fallback(ExBackendWeb.FallbackController)

  # the following plugs are defined in the controllers/authorize.ex file
  plug(:user_check when action in [:index, :show, :delete])
  plug(:right_administrator_check when action in [:index, :show, :delete])

  def swagger_definitions do
    %{
      Credential:
        swagger_schema do
          title("Credential")
          description("A credential of MCAI Backend")

          properties do
            id(:string, "Unique identifier in database")
            inserted_at(:string, "Credential insertion date")
            key(:string, "Credential Key")
            value(:string, "Credential Value")
          end

          example(%{
            id: 1,
            inserted_at: "2022-09-30T15:56:35",
            key: "key",
            value: "value"
          })
        end,
      Credentials:
        swagger_schema do
          title("Credentials")
          description("A collection of Credentials")
          type(:array)
          items(Schema.ref(:Credential))
        end
    }
  end

  swagger_path :index do
    get("/api/credentials")
    summary("List all credentials")
    description("Retrieve all credentials")
    produces("application/json")
    tag("Credentials")

    parameters do
      page(:query, :integer, "Index of the page")
      size(:query, :integer, "Number of items")
      key(:query, :string, "Search by key")
    end

    security([%{Bearer: []}])
    response(200, "OK", Schema.ref(:Credentials))
    response(403, "Unauthorized")
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

  swagger_path :create do
    post("/api/credentials")
    summary("Create credential")
    description("Create credential")
    produces("application/json")
    tag("Credentials")

    parameters do
      key(:query, :string, "Key")
      value(:query, :string, "Value")
    end

    security([%{Bearer: []}])
    response(201, "Created", Schema.ref(:Credential))
    response(403, "Unauthorized")
    response(422, "Unprocessable Entity")
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

  swagger_path :show do
    get("/api/credentials/{key}")
    summary("Get credential (key)")
    description("Get a credential by key")
    produces("application/json")
    tag("Credentials")
    operation_id("get_credential_by_key")

    parameters do
      id(:path, :integer, "Credential key", required: true)
    end

    security([%{Bearer: []}])
    response(200, "OK", Schema.ref(:Credential))
    response(403, "Unauthorized")
  end

  def show(conn, %{"id" => id}) do
    credential = Credentials.get_credential_by_key!(id)
    render(conn, "show.json", credential: credential)
  end

  swagger_path :get_by_key do
    get("/api/credentials/search/{id}")
    summary("Get credential (id)")
    description("Get a credential by id")
    produces("application/json")
    tag("Credentials")
    operation_id("get_credential_by_id")

    parameters do
      id(:path, :string, "Credential ID", required: true)
    end

    security([%{Bearer: []}])
    response(200, "OK", Schema.ref(:Credential))
    response(403, "Unauthorized")
  end

  def get_by_id(conn, %{"id" => id}) do
    credential = Credentials.get_credential!(id)
    render(conn, "show.json", credential: credential)
  end

  swagger_path :delete do
    PhoenixSwagger.Path.delete("/api/credentials/{id}")
    summary("Delete credential")
    description("Delete credential by id")
    produces("application/json")
    tag("Credentials")
    operation_id("delete_user")

    parameters do
      id(:path, :integer, "Credential ID", required: true)
    end

    security([%{Bearer: []}])
    response(204, "No Content")
    response(403, "Unauthorized")
  end

  def delete(conn, %{"id" => id}) do
    credential = Credentials.get_credential!(id)

    with {:ok, %Credential{}} <- Credentials.delete_credential(credential) do
      send_resp(conn, :no_content, "")
    end
  end
end
