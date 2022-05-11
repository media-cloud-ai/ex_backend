defmodule ExBackend.Mailer do
  @moduledoc false

  require Logger

  # Map all your defined mailers here
  @adapters %{
    smtp: ExBackend.SMTPMailer,
    send_grid: ExBackend.SendGridMailer
  }

  def deliver_now(mail) do
    adapter =
      get_adapter_from_config()
      |> String.to_atom()

    delivery = Map.fetch!(@adapters, adapter).deliver_now(mail)

    case delivery do
      {:ok, _mail} -> Logger.info("Mail sent!")
      {:error, error} -> Logger.error("An error occurred on sending the mail: #{inspect(error)}")
    end

    delivery
  end

  defp get_adapter_from_config do
    System.get_env("APP_MAIL_ADAPTER") || Application.get_env(:ex_backend, :mail_adapter, "smtp")
  end
end
