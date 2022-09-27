defmodule ExBackendWeb.StepFlow.Plug do
  @moduledoc false

  use StepFlow.Plug
end

defmodule ExBackendWeb.StepFlowSwagger do
  use Plug.Builder

  plug PhoenixSwagger.Plug.SwaggerUI,
    otp_app: :ex_backend,
    swagger_file: "step_flow_swagger.json"
end
