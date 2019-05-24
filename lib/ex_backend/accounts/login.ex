defmodule ExBackend.Accounts.LoginConfirm do
  use Phauxth.Login.Base

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
end
