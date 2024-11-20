defmodule ExBackendWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :ex_backend

  socket("/socket", ExBackendWeb.UserSocket, websocket: true, longpoll: false)

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug(
    Plug.Static,
    at: "/",
    from: :ex_backend,
    gzip: false,
    only: ~w(favicon.ico robots.txt bundles)
  )

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket("/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket)
    plug(Phoenix.LiveReloader)
    plug(Phoenix.CodeReloader)
  end

  plug(Plug.RequestId)
  plug(Plug.Logger, log: :debug)

  plug(CORSPlug,
    headers: [
      "Authorization",
      "Content-Type",
      "Accept",
      "Origin",
      "User-Agent",
      "DNT",
      "Cache-Control",
      "X-Mx-ReqToken",
      "Keep-Alive",
      "X-Requested-With",
      "If-Modified-Since",
      "X-CSRF-Token",
      "Range"
    ]
  )

  plug(
    Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison
  )

  plug(Plug.MethodOverride)
  plug(Plug.Head)

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug(
    Plug.Session,
    store: :cookie,
    key: "_ex_backend_key",
    signing_salt: "ESY1df/P"
  )

  plug(Pow.Plug.Session,
    otp_app: :ex_backend,
    session_ttl_renewal: :timer.minutes(1),
    credentials_cache_store: {Pow.Store.CredentialsCache, ttl: :timer.minutes(1)}
  )

  # plug(PowPersistentSession.Plug.Cookie,
  #   persistent_session_cookie_key: "token",
  #   persistent_session_ttl: 60_000
  # )

  plug(ExBackendWeb.Router)
end
