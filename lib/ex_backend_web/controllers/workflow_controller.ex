defmodule ExBackendWeb.WorkflowController do
  use ExBackendWeb, :controller

  import ExBackendWeb.Authorize

  alias ExBackend.Workflows
  alias ExBackend.WorkflowStep
  alias ExBackend.Workflows.Workflow

  action_fallback(ExBackendWeb.FallbackController)

  # the following plugs are defined in the controllers/authorize.ex file
  plug(:user_check when action in [:index, :create, :create_specific, :show, :update, :delete])

  plug(
    :right_technician_or_ftvstudio_check
    when action in [:index, :show, :update, :delete]
  )

  def index(conn, params) do
    workflows = Workflows.list_workflows(params)
    render(conn, "index.json", workflows: workflows)
  end

  api :POST, "/api/workflows" do
    title("Create a new workflow")
    description("Start a new worklow.
    <h4>Start a workflow with cURL:</h4>
    <pre class=code>curl \\
    -H \"Authorization: $MIO_TOKEN\" \\
    -H \"Content-Type: application/json\" \\
    -d '{\"workflow\": { \\
      \"reference\": \"dfaaab14-c8f0-4e67-b109-0f5343831d0c\", \\
      \"identifier\": \"Test Transfer\", \\
      \"version_major\": 0, \\
      \"version_minor\": 0, \\
      \"version_micro\": 1, \\
      \"tags\": [\"test\", \"transfer\"], \\
      \"flow\": {\"steps\": [ \\
        {\"id\": 0, \"name\": \"download_ftp\", \"parameters\": [\\
          {\"id\": \"source_hostname\", \"type\": \"credential\", \"default\": \"AKAMAI_REPLAY_HOSTNAME\", \"value\": \"AKAMAI_REPLAY_HOSTNAME\"}, \\
          {\"id\": \"source_username\", \"type\": \"credential\",\"default\":\"AKAMAI_REPLAY_USERNAME\", \"value\": \"AKAMAI_REPLAY_USERNAME\"}, \\
          {\"id\": \"source_password\", \"type\": \"credential\", \"default\": \"AKAMAI_REPLAY_PASSWORD\", \"value\": \"AKAMAI_REPLAY_PASSWORD\"}, \\
          {\"id\": \"source_prefix\", \"type\": \"credential\", \"default\": \"AKAMAI_REPLAY_PREFIX\", \"value\": \"AKAMAI_REPLAY_PREFIX\"}, \\
          {\"default\": \"AKAMAI_REPLAY_SSL\", \"id\": \"source_ssl\", \"type\": \"credential\", \"value\": \"AKAMAI_REPLAY_SSL\"}, \\
          {\"id\": \"source_paths\", \"type\": \"array_of_strings\", \"value\": [\"/streaming-adaptatif_france-dom-tom/2019/S40/J4/213733703-5d95953d73048-standard5.mp4\"]} \\
        ]}
      ]}
    }}' \\
    https://backend.media-io.com/api/workflows</pre>
    ")

    parameter(:reference, :bitstring, description: "UUID of the Reference Media")
    parameter(:identifier, :bitstring, description: "Workflow identifier")
    parameter(:version_major, :bitstring, description: "Workflow version major")
    parameter(:version_minor, :bitstring, description: "Workflow version minor")
    parameter(:version_micro, :bitstring, description: "Workflow version micro")
    parameter(:tags, :array, optional: true, description: "List of tag related to this workflow")
    parameter(:flow, :map, description: "Container of steps")
  end
  def create(conn, %{"workflow" => workflow_params}) do
    IO.inspect(workflow_params)
    case Workflows.create_workflow(workflow_params) do
      {:ok, %Workflow{} = workflow} ->
        WorkflowStep.start_next_step(workflow)

        ExBackendWeb.Endpoint.broadcast!("notifications:all", "new_workflow", %{
          body: %{workflow_id: workflow.id}
        })

        conn
        |> put_status(:created)
        |> render("show.json", workflow: workflow)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(ExBackendWeb.ChangesetView, "error.json", changeset: changeset)
    end
  end

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

  def create_specific(
        conn,
        %{
          "identifier" => "acs",
          "reference" => reference,
          "ttml_path" => ttml_path,
          "mp4_path" => mp4_path
        } = params
      ) do
    dash_manifest_url = Map.get(params, "dash_manifest_url")

    workflow_params =
      ExBackend.Workflow.Definition.FrancetvSubtilAcs.get_definition(
        mp4_path,
        ttml_path,
        dash_manifest_url
      )
      |> Map.put(:reference, reference)

    {:ok, workflow} = Workflows.create_workflow(workflow_params)
    {:ok, "started"} = WorkflowStep.start_next_step(workflow)

    conn
    |> json(%{
      status: "started",
      workflow_id: workflow.id
    })
  end

  def create_specific(conn, %{
        "identifier" => "ingest-dash",
        "reference" => reference,
        "ttml_path" => ttml_path,
        "mp4_paths" => mp4_paths
      }) do
    workflow_params =
      ExBackend.Workflow.Definition.FrancetvSubtilDashIngest.get_definition(mp4_paths, ttml_path)
      |> Map.put(:reference, reference)

    {:ok, workflow} = Workflows.create_workflow(workflow_params)
    {:ok, "started"} = WorkflowStep.start_next_step(workflow)

    conn
    |> json(%{
      status: "started",
      workflow_id: workflow.id
    })
  end

  def create_specific(conn, %{
        "identifier" => "ingest-rosetta",
        "reference" => reference
      }) do
    workflow_params =
      ExVideoFactory.get_ftp_paths_for_video_id(reference)
      |> get_workflow_definition_for_source("ftv_studio_rosetta", reference)
      |> Map.put(:reference, reference)

    {:ok, workflow} = Workflows.create_workflow(workflow_params)
    WorkflowStep.start_next_step(workflow)

    conn
    |> json(%{
      status: "processing",
      workflow_id: workflow.id
    })
  end

  def create_specific(conn, %{
        "identifier" => "ingest-subtil",
        "reference" => reference
      }) do
    workflow_params =
      ExVideoFactory.get_ftp_paths_for_video_id(reference)
      |> get_workflow_definition_for_source("francetv_subtil_rdf_ingest", reference)
      |> Map.put(:reference, reference)

    {:ok, workflow} = Workflows.create_workflow(workflow_params)
    {:ok, response_status} = WorkflowStep.start_next_step(workflow)

    conn
    |> json(%{
      status: response_status,
      workflow_id: workflow.id
    })
  end

  def create_specific(conn, %{
        "identifier" => "ftv-acs-standalone",
        "reference" => reference,
        "audio_url" => audio_url,
        "ttml_url" => ttml_url,
        "destination_url" => destination_url
      }) do

    audio_url = URI.decode(audio_url)
    ttml_url = URI.decode(ttml_url)
    destination_url = URI.decode(destination_url)

    workflow_params =
        ExBackend.Workflow.Definition.FrancetvAcs.get_definition(audio_url, ttml_url, destination_url)
        |> Map.put(:reference, reference)

    {:ok, workflow} = Workflows.create_workflow(workflow_params)
    {:ok, response_status} = WorkflowStep.start_next_step(workflow)

    conn
    |> json(%{
      status: response_status,
      workflow_id: workflow.id
    })
  end

  def create_specific(conn, %{"identifier" => "ftv-acs-standalone"} = params) do
    IO.inspect(params)

    conn
    |> put_status(:unprocessable_entity)
    |> json(%{
      status: "error",
      message: "missing parameters to start acs workflow"
    })
  end

  def create_specific(conn, %{"identifier" => "ingest-dash"} = params) do
    IO.inspect(params)

    conn
    |> put_status(:unprocessable_entity)
    |> json(%{
      status: "error",
      message: "missing parameters to start ingest-dash workflow"
    })
  end

  def create_specific(conn, %{"identifier" => "ingest-subtil"} = params) do
    IO.inspect(params)

    conn
    |> put_status(:unprocessable_entity)
    |> json(%{
      status: "error",
      message: "missing parameters to start ingest-subtil workflow"
    })
  end

  def create_specific(conn, %{"identifier" => "ingest-rosetta"} = params) do
    IO.inspect(params)

    conn
    |> put_status(:unprocessable_entity)
    |> json(%{
      status: "error",
      message: "missing parameters to start ingest-rosetta workflow"
    })
  end

  def create_specific(conn, _params) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{
      status: "error",
      message: "unknown workflow identifier"
    })
  end

  def show(conn, %{"id" => id}) do
    workflow =
      Workflows.get_workflow!(id)
      |> ExBackend.Repo.preload(:jobs)

    render(conn, "show.json", workflow: workflow)
  end

  def get(conn, %{"identifier" => workflow_identifier} = params) do
    workflow =
      case workflow_identifier do
        "ebu_ingest" ->
          ExBackend.Workflow.Definition.EbuIngest.get_definition(
            "#agent_identifier",
            "#input_filename"
          )

        "francetv_subtil_rdf_ingest" ->
          reference = Map.get(params, "reference")
          ExVideoFactory.get_ftp_paths_for_video_id(reference)
          |> get_workflow_definition_for_source("francetv_subtil_rdf_ingest", reference)

        "francetv_subtil_dash_ingest" ->
          ExBackend.Workflow.Definition.FrancetvSubtilDashIngest.get_definition(
            "#mp4_paths",
            "#ttml_path"
          )

        "francetv_subtil_acs" ->
          workflow_reference = Map.get(params, "reference")

          source_mp4_path =
            ExVideoFactory.get_ftp_paths_for_video_id(workflow_reference)
            |> Enum.filter(fn path -> String.contains?(path, "-standard5.mp4") end)
            |> List.first
          source_ttml_path =
            ExVideoFactory.get_http_url_for_ttml(workflow_reference)
            |> List.first()

          ExBackend.Workflow.Definition.FrancetvSubtilAcs.get_definition(
            source_mp4_path,
            source_ttml_path,
            nil
          )

        "ftv_studio_rosetta" ->
          reference = Map.get(params, "reference")
          ExVideoFactory.get_ftp_paths_for_video_id(reference)
          |> get_workflow_definition_for_source("ftv_studio_rosetta", reference)

        "ftv_acs_standalone" ->
          audio_url = Map.get(params, "audio_url")
          ttml_url = Map.get(params, "ttml_url")
          destination_url = Map.get(params, "destination_url")

          ExBackend.Workflow.Definition.FrancetvAcs.get_definition(
            audio_url,
            ttml_url,
            destination_url
          )
      end

    conn
    |> json(workflow)
  end

  def get(conn, _params) do
    conn
    |> json(%{})
  end

  def statistics(conn, params) do
    scale = Map.get(params, "scale", "hour")
    stats = ExBackend.Workflows.get_workflow_history(%{scale: scale})

    conn
    |> json(%{
      data: stats
    })
  end

  def update(conn, %{"id" => id, "workflow" => workflow_params}) do
    workflow = Workflows.get_workflow!(id)

    with {:ok, %Workflow{} = workflow} <- Workflows.update_workflow(workflow, workflow_params) do
      render(conn, "show.json", workflow: workflow)
    end
  end

  def delete(conn, %{"id" => id}) do
    workflow = Workflows.get_workflow!(id)

    with {:ok, %Workflow{}} <- Workflows.delete_workflow(workflow) do
      send_resp(conn, :no_content, "")
    end
  end

  defp get_workflow_definition_for_source(source_paths, workflow_id, workflow_reference) do
    case workflow_id do
      "francetv_subtil_rdf_ingest" ->
          case Enum.find(source_paths, fn path -> String.ends_with?(path, ".ism") end) do
            nil ->
              prefix = "/343079/http"
              mp4_paths =
                source_paths
                |> Enum.filter(fn path ->
                  String.contains?(path, "-standard5.mp4") ||
                    String.contains?(path, "-qad.mp4") ||
                    String.contains?(path, "-qaa.mp4")
                end)
                |> Enum.map(fn path -> String.replace(path, prefix, "") end)

              ttml_path =
                ExVideoFactory.get_http_url_for_ttml(workflow_reference)
                |> List.first()

              ExBackend.Workflow.Definition.FrancetvSubtilRdfIngest.get_definition_for_akamai_input(mp4_paths, ttml_path, prefix)

            manifest_path ->
              source_paths =
                [manifest_path]
                |> Enum.map(fn path -> String.replace_prefix(path, "/", "") end)

              prefix = Path.dirname(manifest_path)

              ExBackend.Workflow.Definition.FrancetvSubtilRdfIngest.get_definition_for_aws_input(source_paths, prefix)
          end

      "ftv_studio_rosetta" ->
          upload_pattern =
            ExBackend.Workflow.Definition.FtvStudioRosetta.get_output_filename_base(workflow_reference)

          case Enum.find(source_paths, fn path -> String.ends_with?(path, ".ism") end) do
            nil ->
              prefix = "/343079/http"
              mp4_paths =
                source_paths
                |> Enum.filter(fn path -> String.contains?(path, "-standard5.mp4") end)
                |> Enum.map(fn path -> String.replace(path, prefix, "") end)

              ttml_path =
                ExVideoFactory.get_http_url_for_ttml(workflow_reference)
                |> List.first()

              ExBackend.Workflow.Definition.FtvStudioRosetta.get_definition_for_akamai_input(mp4_paths, ttml_path, upload_pattern, prefix)

            manifest_path ->
              source_paths =
                [manifest_path]
                |> Enum.map(fn path -> String.replace_prefix(path, "/", "") end)

              prefix = Path.dirname(manifest_path)

              ExBackend.Workflow.Definition.FtvStudioRosetta.get_definition_for_aws_input(source_paths, upload_pattern, prefix)
          end
   end
  end
end
