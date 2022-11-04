defmodule ExBackendWeb.StepFlow.Plug do
  @moduledoc false

  use StepFlow.Plug
end

defmodule ExBackendWeb.StepFlowSwaggerUI do
  @moduledoc false

  use Plug.Builder

  plug(OpenApiSpex.Plug.SwaggerUI,
    path: "/api/step_flow/openapi"
  )
end
