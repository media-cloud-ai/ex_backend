defmodule ExBackendWeb.ApiSpec do
  @moduledoc false

  alias OpenApiSpex.{Components, Info, OpenApi, Paths, SecurityScheme}
  @behaviour OpenApi

  @impl OpenApi
  def spec do
    %OpenApi{
      info: %Info{
        title: "MCAI Backend",
        version: Application.spec(:ex_backend)[:vsn] |> to_string()
      },
      paths: Paths.from_router(ExBackendWeb.Router),
      components: %Components{
        securitySchemes: %{"authorization" => %SecurityScheme{type: "http", scheme: "bearer"}}
      }
    }
    |> OpenApiSpex.resolve_schema_modules()
  end
end
