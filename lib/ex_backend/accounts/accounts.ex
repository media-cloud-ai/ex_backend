defmodule ExBackend.Accounts do
  @moduledoc """
  The boundary for the Accounts system.
  """

  import Ecto.{Query, Changeset}, warn: false
  alias Phauxth.Log
  alias ExBackend.{Accounts.User, Repo}
  alias StepFlow.Controllers.Roles

  defp force_integer(param) when is_bitstring(param) do
    param
    |> String.to_integer()
  end

  defp force_integer(param) do
    param
  end

  def list_users(params \\ %{}) do
    page =
      Map.get(params, "page", 0)
      |> force_integer

    size =
      Map.get(params, "size", 10)
      |> force_integer

    offset = page * size

    query = from(user in User)

    total_query = from(item in query, select: count(item.id))

    total =
      Repo.all(total_query)
      |> List.first()

    query =
      from(
        user in query,
        order_by: [desc: :inserted_at],
        offset: ^offset,
        limit: ^size
      )

    users = Repo.all(query)

    %{
      data: users,
      total: total,
      page: page,
      size: size
    }
  end

  def get(id), do: Repo.get(User, id)

  def get_by(%{"email" => email}) do
    Repo.get_by(User, email: email)
  end

  def get_by(%{"uuid" => uuid}) do
    Repo.get_by(User, uuid: uuid)
  end

  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def confirm_user(%User{} = user) do
    change(user, %{confirmed_at: DateTime.utc_now()})
    |> Repo.update()
  end

  def create_password_reset(attrs) do
    with %User{} = user <- get_by(attrs) do
      change(user, %{reset_sent_at: DateTime.utc_now()}) |> Repo.update()
      Log.info(%Log{user: user.id, message: "password reset requested"})
      user
    end
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def update_password(%User{} = user, attrs) do
    user
    |> User.password_changeset(attrs)
    |> change(%{reset_sent_at: nil})
    |> Repo.update()
  end

  def update_credentials(%User{} = user) do
    user
    |> User.changeset_credentials()
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  def check_user_rights(user, entity, action) do
    has_right =
      user.roles
      |> Enum.map(fn role -> StepFlow.Roles.get_by(%{"name" => role}) end)
      |> Roles.has_right?(entity, action)

    {:ok, has_right}
  end

  def delete_users_role(%{role: role_name}) do
    query =
      from(
        user in User,
        where: ^role_name in user.roles
      )

    total_query = from(item in query, select: count(item.id))

    total =
      Repo.all(total_query)
      |> List.first()

    users = Repo.all(query)

    user_emails =
      users
      |> Enum.map(fn user ->
        new_roles =
          user.roles
          |> List.delete(role_name)

        {user, %{roles: new_roles}}
      end)
      |> Enum.map(fn {user, new_roles} ->
        update_user(user, new_roles)
      end)
      |> Enum.map(fn {_result, user} -> user.email end)

    %{
      data: user_emails,
      total: total,
      page: 0,
      size: length(user_emails)
    }
  end
end
