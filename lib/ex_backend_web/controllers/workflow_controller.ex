defmodule ExBackendWeb.WorkflowController do
  use ExBackendWeb, :controller
  require Logger

  import ExBackendWeb.Authorize

  alias StepFlow.Workflows
  alias StepFlow.Step

  action_fallback(ExBackendWeb.FallbackController)

  # the following plugs are defined in the controllers/authorize.ex file
  plug(:user_check when action in [:create_specific])

  api :POST, "/api/workflow/:identifier" do
    title("Create a new workflow with a specific template")
    description("Start a new worklow. The identifier will select the template.
    <h4>Start an Automatic Content Synchronisation workflow with cURL:</h4>
    <pre class=code>curl \\
    -H \"Authorization: $MIO_TOKEN\" \\
    -H \"Content-Type: application/json\" \\
    -d '{ \\
      \"reference\": \"d953ffd8-53a4-49ed-9312-c1ba78bdd5f4\", \\
      \"mp4_path\": \"/streaming-adaptatif/2018/S50/J1/194377135-5c0dfc6eb3420-standard1.mp4\", \\
      \"ttml_path\": \"https://staticftv-a.akamaihd.net/sous-titres/2018/12/10/194377135-5c0dfc6eb3420-1544422463.ttml\" \\
    }' \\
    https://backend.media-io.com/api/workflow/acs</pre>
    ")

    parameter(:identifier, :bitstring,
      description: "Identifier of the workflow (one of [acs, ingest-dash])"
    )

    parameter(:reference, :bitstring, description: "UUID of the Reference Media")
    parameter(:ttml_path, :bitstring, description: "URL to the TTML")
    parameter(:mp4_path, :bitstring, description: "Path to the MP4 to retrieve the audio")

    parameter(:dash_manifest_url, :bitstring,
      description: "(Optional) HTTP URL to the Manifest DASH"
    )
  end

  def create_specific(conn, %{
        "identifier" => "ingest-rosetta",
        "reference" => reference
      }) do
    source_paths = ExVideoFactory.get_ftp_paths_for_video_id(reference)

    source_folder =
      Enum.find(source_paths, fn path -> String.ends_with?(path, ".ism") end)
      |> String.split("/")
      |> Enum.at(1)

    extra_parameters =
      ExBackend.Workflow.Definition.FtvStudioRosetta.get_extra_parameters(reference)

    workflow_params =
      ExVideoFactory.get_ftp_paths_for_video_id(reference)
      |> get_workflow_definition_for_source("ftv_studio_rosetta", reference)
      |> Map.put(:reference, reference)
      |> Map.put(
        :parameters,
        extra_parameters ++
          [
            %{
              id: "source_folder",
              type: "string",
              value: source_folder
            }
          ]
      )

    {:ok, workflow} = Workflows.create_workflow(workflow_params)
    {:ok, _response_status} = Step.start_next(workflow)

    conn
    |> json(%{
      status: "processing",
      workflow_id: workflow.id
    })
  end

  def create_specific(conn, %{"identifier" => "ingest-rosetta"} = _params) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{
      status: "error",
      message: "missing parameters to start ingest-rosetta workflow"
    })
  end

  def create_specific(conn, params) do
    Logger.warn("unable to start workflow: #{inspect(params)}")

    conn
    |> put_status(:unprocessable_entity)
    |> json(%{
      status: "error",
      message: "unknown workflow identifier"
    })
  end

  defp get_workflow_definition_for_source(source_paths, workflow_id, workflow_reference) do
    case workflow_id do
      "ftv_studio_rosetta" ->
        extra_parameters =
          ExBackend.Workflow.Definition.FtvStudioRosetta.get_extra_parameters(workflow_reference)

        case Enum.find(source_paths, fn path -> String.ends_with?(path, ".ism") end) do
          nil ->
            mp4_paths =
              source_paths
              |> Enum.filter(fn path -> String.contains?(path, "-standard5.mp4") end)
              |> Enum.map(fn path -> String.replace(path, "/343079/http", "") end)

            ttml_path =
              ExVideoFactory.get_http_url_for_ttml(workflow_reference)
              |> List.first()

            ExBackend.Workflow.Definition.FtvStudioRosetta.get_definition_for_akamai_input(
              mp4_paths,
              ttml_path,
              extra_parameters
            )

          manifest_path ->
            source_paths =
              [manifest_path]
              |> Enum.map(fn path -> String.replace_prefix(path, "/", "") end)

            extra_parameters = []

            ttml_path =
              ExVideoFactory.get_http_url_for_ttml(workflow_reference)
              |> List.first()

            ExBackend.Workflow.Definition.FtvStudioRosetta.get_definition_for_aws_input(
              source_paths,
              ttml_path,
              extra_parameters
            )
        end
    end
  end
end
