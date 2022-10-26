defmodule ExBackendWeb.PasswordResetController do
  use ExBackendWeb, :controller
  use OpenApiSpex.ControllerSpecs

  require Logger

  import ExBackendWeb.Authorize
  alias ExBackend.Accounts
  alias ExBackendWeb.Auth.Token
  alias ExBackendWeb.OpenApiSchemas

  tags ["Users"]
  security [%{"authorization" => %OpenApiSpex.SecurityScheme{type: "http", scheme: "bearer"}}]

  plug(:guest_check when action in [:create, :update])

  operation :create,
    summary: "Reset a password",
    description: "Reset a password",
    type: :object,
    request_body:
      {"Session Body", "application/json", OpenApiSchemas.Passwords.PasswordResetBody},
    responses: [
      created: "Check your inbox for instructions on how to reset your password",
      forbidden: "Forbidden"
    ]

  def create(conn, %{"password_reset" => %{"email" => email}}) do
    case Accounts.create_password_reset(%{"email" => email}) do
      nil ->
        message = "Could not find an user based on this address"

        conn
        |> put_status(:not_found)
        |> put_view(ExBackendWeb.PasswordResetView)
        |> render("error.json", error: message)

      user ->
        token = Token.sign(%{"email" => user.email})

        case Accounts.Message.reset_request(email, token) do
          {:ok, _sent_mail} ->
            message = "Check your inbox for instructions on how to reset your password"

            conn
            |> put_status(:created)
            |> put_view(ExBackendWeb.PasswordResetView)
            |> render("info.json", info: message)

          {:error, error} ->
            Logger.error("Email delivery failure: #{inspect(error)}")

            conn
            |> send_resp(500, "Internal Server Error")
        end
    end
  end

  operation :update,
    summary: "Update a password",
    description: "Update a password",
    type: :object,
    request_body:
      {"Session Body", "application/json", OpenApiSchemas.Passwords.PasswordUpdateBody},
    responses: [
      ok: "Your password has been reset",
      forbidden: "Forbidden"
    ]

  def update(conn, %{"password_reset" => params}) do
    case Token.verify(params, mode: :pass_reset) do
      {:ok, nil} ->
        put_status(conn, :unprocessable_entity)
        |> put_view(ExBackendWeb.PasswordResetView)
        |> render("error.json", error: "Could not find the user in the database")

      {:ok, user} ->
        user
        |> Accounts.update_password(params)
        |> update_password(conn, params)

      {:error, message} ->
        put_status(conn, :unprocessable_entity)
        |> put_view(ExBackendWeb.PasswordResetView)
        |> render("error.json", error: message)
    end
  end

  defp update_password({:ok, user}, conn, _params) do
    case Accounts.Message.reset_success(user.email) do
      {:ok, _sent_mail} ->
        message = "Your password has been reset"

        conn
        |> put_view(ExBackendWeb.PasswordResetView)
        |> render("info.json", %{info: message})

      {:error, error} ->
        Logger.error("Email delivery failure: #{inspect(error)}")

        conn
        |> send_resp(500, "Internal Server Error")
    end
  end

  defp update_password({:error, %Ecto.Changeset{} = changeset}, conn, _params) do
    message = with p <- changeset.errors[:password], do: elem(p, 0)

    put_status(conn, :unprocessable_entity)
    |> put_view(ExBackendWeb.PasswordResetView)
    |> render(
      "error.json",
      error: message || "Invalid input"
    )
  end
end
