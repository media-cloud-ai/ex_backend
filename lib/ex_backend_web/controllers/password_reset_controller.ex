defmodule ExBackendWeb.PasswordResetController do
  use ExBackendWeb, :controller
  alias ExBackend.Accounts

  def create(conn, %{"password_reset" => %{"email" => email}}) do
    case Accounts.create_password_reset(%{"email" => email}) do
      nil ->
        message = "unable to found user based on email address"

        put_status(conn, :unprocessable_entity)
        |> put_view(ExBackendWeb.PasswordResetView)
        |> render("error.json", error: message)

      user ->
        token = ExBackendWeb.Auth.Token.sign(%{"email" => user.email})

        Accounts.Message.reset_request(email, token)
        message = "Check your inbox for instructions on how to reset your password"

        conn
        |> put_status(:created)
        |> put_view(ExBackendWeb.PasswordResetView)
        |> render("info.json", %{info: message})
    end
  end

  def update(conn, %{"password_reset" => params}) do
    case ExBackendWeb.Auth.Token.verify(params, mode: :pass_reset) do
      {:ok, nil} ->
        put_status(conn, :unprocessable_entity)
        |> put_view(ExBackendWeb.PasswordResetView)
        |> render("error.json", error: "unable to found user in the database")

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
    Accounts.Message.reset_success(user.email)
    message = "Your password has been reset"

    conn
    |> put_view(ExBackendWeb.PasswordResetView)
    |> render("info.json", %{info: message})
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
