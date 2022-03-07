defmodule ExBackend.Accounts.MessageTest do
  use ExUnit.Case
  use Bamboo.Test

  import ExBackendWeb.AuthCase
  alias ExBackend.Accounts.Message

  setup do
    email = "deirdre@example.com"
    {:ok, %{email: email, key: gen_key(email)}}
  end

  test "sends confirmation request email", %{email: email, key: key} do
    {:ok, sent_email} = Message.confirm_request(email, key)
    assert sent_email.subject =~ "Confirm your account"
    assert sent_email.text_body =~ "Confirm your email here"
    assert sent_email.text_body =~ "/confirm?key="
    assert_delivered_email(sent_email)
  end

  test "sends no user found message for password reset attempt" do
    {:ok, sent_email} = Message.reset_request("gladys@example.com", nil)
    assert sent_email.text_body =~ "but no user is associated with the email you provided"
  end

  test "sends reset password request email", %{email: email, key: key} do
    {:ok, sent_email} = Message.reset_request(email, key)
    assert sent_email.subject =~ "Reset your password"
    assert sent_email.text_body =~ "Reset your password at "
    assert sent_email.text_body =~ "/password_resets/edit?key="
    assert_delivered_email(sent_email)
  end

  test "sends receipt confirmation email", %{email: email} do
    {:ok, sent_email} = Message.confirm_success(email)
    assert sent_email.text_body =~ "account has been confirmed"
    assert_delivered_email(sent_email)
  end

  test "sends password reset email", %{email: email} do
    {:ok, sent_email} = Message.reset_success(email)
    assert sent_email.text_body =~ "password has been reset"
    assert_delivered_email(sent_email)
  end
end
