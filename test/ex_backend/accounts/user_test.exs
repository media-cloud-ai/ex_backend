defmodule ExBackend.UserTest do
  use ExUnit.Case

  alias ExBackend.Accounts.User

  test "set already present username attribute" do
    attrs = %{username: "My user"}

    assert attrs == User.set_username_attribute(attrs)

    attrs = %{"username" => "My user"}

    assert attrs == User.set_username_attribute(attrs)

    attrs = %{username: "My user", first_name: "My", last_name: "User"}

    assert attrs == User.set_username_attribute(attrs)

    attrs = %{"username" => "My user", "first_name" => "My", "last_name" => "User"}

    assert attrs == User.set_username_attribute(attrs)
  end

  test "set username attribute from first and last names" do
    attrs = %{first_name: "My", last_name: "User"}

    expected_attrs = %{username: "muser", first_name: "My", last_name: "User"}

    assert expected_attrs == User.set_username_attribute(attrs)

    attrs = %{"first_name" => "My", "last_name" => "User"}

    expected_attrs = %{"username" => "muser", "first_name" => "My", "last_name" => "User"}

    assert expected_attrs == User.set_username_attribute(attrs)

    attrs = "whatever"

    assert attrs == User.set_username_attribute(attrs)
  end

  test "set username attribute from any other value" do
    attrs = "whatever"

    assert attrs == User.set_username_attribute(attrs)
  end
end
