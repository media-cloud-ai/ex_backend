defmodule ExBackend.AccountsTest do
  use ExBackend.DataCase

  alias ExBackend.Accounts
  alias ExBackend.Accounts.User

  @create_attrs %{
    first_name: "Fred",
    last_name: "Toll",
    email: "fred@example.com",
    password: "reallyHard2gue$$"
  }
  @update_attrs %{email: "frederick@example.com"}
  @invalid_attrs %{email: "", password: ""}

  def fixture(:user, attrs \\ @create_attrs) do
    {:ok, user} = Accounts.create_user(attrs)
    user
  end

  test "list_users/1 returns all users" do
    user = fixture(:user)

    assert Accounts.list_users() == %{
             data: [user],
             page: 0,
             size: 10,
             total: 1
           }
  end

  test "get returns the user with given id" do
    user = fixture(:user)
    assert Accounts.get(user.id) == user
  end

  test "create_user/1 with valid data creates a user" do
    assert {:ok, %User{} = user} = Accounts.create_user(@create_attrs)
    assert user.email == "fred@example.com"
    assert String.length(user.uuid) == 36

    assert Regex.match?(
             ~r/^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}/,
             user.uuid
           ) == true
  end

  test "create_user/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
  end

  test "update_user/2 with valid data updates the user" do
    user = fixture(:user)
    assert {:ok, user} = Accounts.update_user(user, @update_attrs)
    assert %User{} = user
    assert user.email == "frederick@example.com"
  end

  test "update_user/2 with invalid data returns error changeset" do
    user = fixture(:user)
    assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
    assert user == Accounts.get(user.id)
  end

  test "delete_user/1 deletes the user" do
    user = fixture(:user)
    assert {:ok, %User{}} = Accounts.delete_user(user)
    refute Accounts.get(user.id)
  end

  test "change_user/1 returns a user changeset" do
    user = fixture(:user)
    assert %Ecto.Changeset{} = Accounts.change_user(user)
  end

  test "update password changes the stored hash" do
    %{password_hash: stored_hash} = user = fixture(:user)
    attrs = %{password: "CN8W6kpb"}
    {:ok, %{password_hash: hash}} = Accounts.update_password(user, attrs)
    assert hash != stored_hash
  end

  test "update_password with weak password fails" do
    user = fixture(:user)
    attrs = %{password: "pass"}
    assert {:error, %Ecto.Changeset{}} = Accounts.update_password(user, attrs)
  end

  test "update credentials" do
    user = fixture(:user)
    {:ok, %User{}} = Accounts.update_credentials(user)
    user = Accounts.get(user.id)
    <<head::binary-size(4)>> <> _rest = user.access_key_id
    assert head == "MCAI"
    assert String.length(user.access_key_id) == 20
    assert Regex.match?(~r/[^\d]/, user.access_key_id) == true
    assert String.length(user.secret_access_key) == 40
  end
end
