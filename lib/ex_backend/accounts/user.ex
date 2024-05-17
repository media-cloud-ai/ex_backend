defmodule ExBackend.Accounts.User do
  @moduledoc false

  use Ecto.Schema
  use Pow.Ecto.Schema, password_hash_verify: {&Bcrypt.hash_pwd_salt/1, &Bcrypt.verify_pass/2}
  use PowAssent.Ecto.Schema

  import Ecto.Changeset
  alias ExBackend.Accounts.User
  alias ExBackend.Filters
  alias ExBackend.Repo

  schema "users" do
    pow_user_fields()

    field(:roles, {:array, :string}, default: [])
    field(:confirmed_at, :utc_datetime_usec)
    field(:reset_sent_at, :utc_datetime_usec)
    field(:uuid, :string)
    field(:access_key_id, :string)
    field(:secret_access_key, :string)
    field(:first_name, :string)
    field(:last_name, :string)
    field(:username, :string)
    has_many(:filters, Filters, on_delete: :delete_all)

    timestamps()
  end

  def changeset(%User{} = user, attrs, is_root \\ false) do
    uuid = Ecto.UUID.generate()

    attrs =
      if user.uuid == nil do
        if Map.get(attrs, :email) || Map.get(attrs, :roles) do
          Map.put(attrs, :uuid, uuid)
        else
          Map.put(attrs, "uuid", uuid)
        end
      else
        attrs
      end

    attrs = set_username_attribute(attrs)

    user
    |> cast(attrs, user_cast(is_root))
    |> validate_required([:email, :first_name, :last_name, :username, :uuid])
    |> unique_email
  end

  def set_username_attribute(%{username: _} = attrs), do: attrs
  def set_username_attribute(%{"username" => _} = attrs), do: attrs

  def set_username_attribute(%{first_name: first_name, last_name: last_name} = attrs) do
    username =
      (String.at(first_name, 0) <> last_name)
      |> String.downcase()

    Map.put(attrs, :username, username)
  end

  def set_username_attribute(%{"first_name" => first_name, "last_name" => last_name} = attrs) do
    username =
      (String.at(first_name, 0) <> last_name)
      |> String.downcase()

    Map.put(attrs, "username", username)
  end

  def set_username_attribute(attrs), do: attrs

  defp user_cast(is_root) do
    if is_root do
      [:email, :first_name, :last_name, :username, :roles, :uuid, :id]
    else
      [:email, :first_name, :last_name, :username, :roles, :uuid]
    end
  end

  def changeset_user(%User{} = user, attrs) do
    changeset(user, attrs)
  end

  defp changeset_root(%User{} = user, attrs) do
    changeset(user, attrs, true)
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

  def create_root_user(attrs) do
    changeset_root(%User{}, attrs)
    |> Repo.insert()
  end

  def generate_root_password do
    credential_generator(16, false, false)
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
    change(changeset, %{:password_hash => Bcrypt.hash_pwd_salt(password)})
  end

  defp put_pass_hash(changeset), do: changeset

  defp strong_password?(password) when byte_size(password) > 7 do
    {:ok, password}
  end

  defp strong_password?(_), do: {:error, "The password is too short"}

  # In the function below, a random bytes chain is generated to be transformed
  # in an alphanumeric string in order to be used as a credential
  defp credential_generator(length, is_upcase \\ false, is_padding \\ true) do
    creds =
      :crypto.strong_rand_bytes(length)
      |> Base.url_encode64(padding: is_padding)

    if is_upcase do
      creds
      |> String.upcase()
      |> String.replace("-", "D")
      |> String.replace("_", "U")
    else
      creds
    end
  end

  def set_workflow_filters(%User{} = user, filters) do
    user
    |> changeset_user(%{
      workflow_filters: filters
    })
    |> Repo.update()
  end

  # Redefined from Pow Assent in order to implement custom fields from IP response
  def user_identity_changeset(user_or_changeset, user_identity, attrs, user_id_attrs) do
    name_split = String.split(attrs["name"], " ")
    first_name = List.first(name_split)
    last_name = List.last(name_split)

    attrs =
      attrs
      |> Map.put("confirmed_at", DateTime.utc_now())
      |> Map.put("first_name", first_name)
      |> Map.put("last_name", last_name)
      |> Map.delete("username")
      |> set_username_attribute()

    user_or_changeset
    |> cast(attrs, [:confirmed_at, :first_name, :last_name, :username])
    |> pow_assent_user_identity_changeset(user_identity, attrs, user_id_attrs)
  end
end
