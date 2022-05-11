defmodule ExBackendWeb.S3Controller do
  use ExBackendWeb, :controller

  import ExBackendWeb.Authorize

  # alias ExBackend.Registeries
  # alias ExBackend.Subtitles

  action_fallback(ExBackendWeb.FallbackController)

  # the following plugs are defined in the controllers/authorize.ex file
  # plug(:user_check when action in [:index])
  # plug(:right_editor_check when action in [:index])

  def config(conn, _params) do
    url = System.get_env("S3_URL") || Application.get_env(:ex_backend, :s3_url)

    access_key =
      System.get_env("S3_ACCESS_KEY") || Application.get_env(:ex_backend, :s3_access_key)

    region = System.get_env("S3_REGION") || Application.get_env(:ex_backend, :s3_region)
    bucket = System.get_env("S3_BUCKET") || Application.get_env(:ex_backend, :s3_bucket)

    vod_endpoint =
      System.get_env("VOD_ENDPOINT") || Application.get_env(:ex_backend, :vod_endpoint)

    config = %{
      url: url,
      access_key: access_key,
      region: region,
      bucket: bucket,
      vod_endpoint: vod_endpoint
    }

    json(conn, config)
  end

  def signer(conn, %{"to_sign" => string_to_sign}) do
    [_algorithm, _datetime, url, _hash] =
      string_to_sign
      |> String.split("\n")

    [date, region, service, "aws4_request"] =
      url
      |> String.split("/")

    secret_key =
      System.get_env("S3_SECRET_KEY") || Application.get_env(:ex_backend, :s3_secret_key)

    date_key = :crypto.mac(:hmac, :sha256, "AWS4" <> secret_key, date)
    date_region_key = :crypto.mac(:hmac, :sha256, date_key, region)
    date_region_service_key = :crypto.mac(:hmac, :sha256, date_region_key, service)
    signing_key = :crypto.mac(:hmac, :sha256, date_region_service_key, "aws4_request")

    signature = :crypto.mac(:hmac, :sha256, signing_key, string_to_sign)
    text(conn, signature |> Base.encode16(case: :lower))
  end

  def signer(conn, _), do: error(conn, :unprocessable_entity, 422)

  def presign_url(conn, %{"path" => path} = params) do
    bucket =
      Map.get(params, "bucket") ||
        System.get_env("S3_BUCKET") ||
        Application.get_env(:ex_backend, :s3_bucket)

    url = make_presigned_url(path, bucket)

    conn
    |> json(%{url: url})
  end

  def presign_url(conn, _), do: error(conn, :unprocessable_entity, 422)

  defp make_presigned_url(path, bucket) do
    s3_url = System.get_env("S3_URL") || Application.get_env(:ex_backend, :s3_url)

    url =
      s3_url
      |> String.replace("https://", "")
      |> String.replace("http://", "")

    scheme =
      if String.starts_with?(s3_url, "https://") do
        "https://"
      else
        "http://"
      end

    region = System.get_env("S3_REGION") || Application.get_env(:ex_backend, :s3_region)

    access_key =
      System.get_env("S3_ACCESS_KEY") || Application.get_env(:ex_backend, :s3_access_key)

    secret_key =
      System.get_env("S3_SECRET_KEY") || Application.get_env(:ex_backend, :s3_secret_key)

    query_params = [
      {"ACL", "public-read"}
    ]

    presign_options = [query_params: query_params]

    config = %{
      access_key_id: access_key,
      secret_access_key: secret_key,
      http_client: ExAws.Request.Hackney,
      json_codec: Jason,
      retries: [
        max_attempts: 10,
        base_backoff_in_ms: 10,
        max_backoff_in_ms: 10_000
      ],
      scheme: scheme,
      region: region,
      port: 443,
      host: url
    }

    {:ok, presigned_url} = ExAws.S3.presigned_url(config, :get, bucket, path, presign_options)

    presigned_url
  end
end
