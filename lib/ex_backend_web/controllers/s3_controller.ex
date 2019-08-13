defmodule ExBackendWeb.S3Controller do
  use ExBackendWeb, :controller

  import ExBackendWeb.Authorize

  alias ExBackend.Registeries
  alias ExBackend.Subtitles

  action_fallback(ExBackendWeb.FallbackController)

  # the following plugs are defined in the controllers/authorize.ex file
  # plug(:user_check when action in [:index])
  # plug(:right_editor_check when action in [:index])

  def config(conn, params) do
    config = %{}
    
    json(conn, config)
  end

  def signer(conn, %{"to_sign" => string_to_sign}) do
    [_algorithm, _datetime, url, _hash] =
      string_to_sign
      |> String.split("\n")

    [date, region, service, "aws4_request"] =
      url
      |> String.split("/")

    secret_key = System.get_env("AWS_SECRET_KEY") || Application.get_env(:ex_backend, :aws_secret_key)

    date_key = :crypto.hmac(:sha256, "AWS4" <> secret_key, date)
    date_region_key = :crypto.hmac(:sha256, date_key, region)
    date_region_service_key = :crypto.hmac(:sha256, date_region_key, service)
    signing_key = :crypto.hmac(:sha256, date_region_service_key, "aws4_request")

    signature = :crypto.hmac(:sha256, signing_key, string_to_sign)
    text(conn, signature |> Base.encode16(case: :lower))
  end
end
