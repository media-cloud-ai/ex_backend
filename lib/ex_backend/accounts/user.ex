defmodule ExBackend.Accounts.User do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias ExBackend.Accounts.User
  alias ExBackend.Repo

  schema "users" do
    field(:email, :string)
    field(:password, :string, virtual: true)
    field(:password_hash, :string)
    field(:roles, {:array, :string}, default: ["administrator"])
    field(:confirmed_at, :utc_datetime_usec)
    field(:reset_sent_at, :utc_datetime_usec)
    field(:uuid, :string)
    field(:access_key_id, :string)
    field(:secret_access_key, :string)

    timestamps()
  end

  def changeset(%User{} = user, attrs) do
    uuid = Ecto.UUID.generate()

    attrs =
      if Map.get(attrs, :email) || Map.get(attrs, :roles) do
        Map.put(attrs, :uuid, uuid)
      else
        Map.put(attrs, "uuid", uuid)
      end

    user
    |> cast(attrs, [:email, :roles, :uuid])
    |> validate_required([:email, :uuid])
    |> unique_email
  end

  def changeset_credentials(%User{} = user) do
    access_key_id = "MCAI" <> credential_generator(12, true)
    secret_access_key = credential_generator(28)

    user
    |> cast(%{access_key_id: access_key_id, secret_access_key: secret_access_key}, [
      :access_key_id,
      :secret_access_key
    ])
    |> validate_required([:access_key_id, :secret_access_key])
  end

  def password_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:password])
    |> validate_required([:password])
    |> validate_password(:password)
    |> put_pass_hash
  end

  def get_by(%{"access_key_id" => access_key_id}) do
    Repo.get_by(User, access_key_id: access_key_id)
  end

  def verify_secret_access_key(user, secret_access_key) do
    secret_access_key == user.secret_access_key
  end

  defp unique_email(changeset) do
    validate_format(changeset, :email, ~r/@/)
    |> validate_length(:email, max: 254)
    |> unique_constraint(:email)
  end

  # In the function below, strong_password? just checks that the password
  # is at least 8 characters long.
  # See the documentation for NotQwerty123.PasswordStrength.strong_password?
  # for a more comprehensive password strength checker.
  defp validate_password(changeset, field, options \\ []) do
    validate_change(changeset, field, fn _, password ->
      case strong_password?(password) do
        {:ok, _} -> []
        {:error, msg} -> [{field, options[:message] || msg}]
      end
    end)
  end

  # If you are using Argon2 or Pbkdf2, change Bcrypt to Argon2 or Pbkdf2
  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, Bcrypt.add_hash(password))
  end

  defp put_pass_hash(changeset), do: changeset

  defp strong_password?(password) when byte_size(password) > 7 do
    {:ok, password}
  end

  defp strong_password?(_), do: {:error, "The password is too short"}

  # In the function below, a random bytes chain is generated to be transformed
  # in an alphanumeric string in order to be used as a credential
  defp credential_generator(length, is_upcase \\ false) do
    creds =
      :crypto.strong_rand_bytes(length)
      |> Base.url_encode64(padding: true)

    if is_upcase do
      creds
      |> String.upcase()
      |> String.replace("-", "D")
      |> String.replace("_", "U")
    else
      creds
    end
  end
end
