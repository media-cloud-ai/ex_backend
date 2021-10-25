defmodule ExBackend.Accounts.LoginConfirm do
  @moduledoc false

  use Phauxth.Login.Base
  alias ExBackend.Accounts.User

  def authenticate(%{"password" => password} = params) do
    case Config.user_context().get_by(params) do
      nil ->
        {:error, "no user found"}

      %{confirmed_at: nil} ->
        {:error, "account unconfirmed"}

      user ->
        if Bcrypt.verify_pass(password, user.password_hash) == true do
          {:ok, user}
        else
          {:error, "bad password"}
        end
    end
  end

  def authenticate_credentials(%{
        "access_key_id" => access_key_id,
        "secret_access_key" => secret_access_key
      }) do
    case User.get_by(%{"access_key_id" => access_key_id}) do
      nil ->
        {:error, "no user found"}

      user ->
        if User.verify_secret_access_key(user, secret_access_key) == true do
          {:ok, user}
        else
          {:error, "bad password"}
        end
    end
  end
end
