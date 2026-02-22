defmodule ExBackendWeb.StepFlow.Plugs.StepFlow do
  @moduledoc false

  use StepFlow.Plugs.StepFlow
end

defmodule ExBackendWeb.StepFlow.Plugs.Prometheus do
  @moduledoc false

  use StepFlow.Plugs.Prometheus
end

defmodule ExBackendWeb.StepFlowSwaggerUI do
  @moduledoc false

  use Plug.Builder

  plug(OpenApiSpex.Plug.SwaggerUI,
    path: "/api/step_flow/openapi"
  )
end
