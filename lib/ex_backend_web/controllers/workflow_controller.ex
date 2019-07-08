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
    when action in [:index, :create, :create_specific, :show, :update, :delete]
  )

  def index(conn, params) do
    workflows = Workflows.list_workflows(params)
    render(conn, "index.json", workflows: workflows)
  end

  def create(conn, %{"workflow" => workflow_params}) do
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
    <pre class=code>curl -H \"Authorization: $MIO_TOKEN\" -H \"Content-Type: application/json\" -d '{\"reference\": \"d953ffd8-53a4-49ed-9312-c1ba78bdd5f4\", \"mp4_path\": \"/streaming-adaptatif/2018/S50/J1/194377135-5c0dfc6eb3420-standard1.mp4\", \"ttml_path\": \"https://staticftv-a.akamaihd.net/sous-titres/2018/12/10/194377135-5c0dfc6eb3420-1544422463.ttml\"}' https://backend.media-io.com/api/workflow/acs</pre>
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
    upload_pattern =
      ExBackend.Workflow.Definition.FtvStudioRosetta.get_output_filename_base(reference)

    mp4_paths =
      ExVideoFactory.get_ftp_paths_for_video_id(reference)
      |> Enum.filter(fn path -> String.contains?(path, "-standard5.mp4") end)
      |> Enum.map(fn path -> String.replace(path, "/343079/http", "") end)

    ttml_path =
      ExVideoFactory.get_http_url_for_ttml(reference)
      |> List.first()

    workflow_params =
      ExBackend.Workflow.Definition.FtvStudioRosetta.get_definition(
        mp4_paths,
        ttml_path,
        upload_pattern
      )
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
    mp4_paths =
      ExVideoFactory.get_ftp_paths_for_video_id(reference)
      |> Enum.filter(fn path ->
        String.contains?(path, "-standard5.mp4") ||
          String.contains?(path, "-qad.mp4") ||
          String.contains?(path, "-qaa.mp4")
      end)
      |> Enum.map(fn path -> String.replace(path, "/343079/http", "") end)

    ttml_path =
      ExVideoFactory.get_http_url_for_ttml(reference)
      |> List.first()

    workflow_params =
      ExBackend.Workflow.Definition.FrancetvSubtilRdfIngest.get_definition(mp4_paths, ttml_path)
      |> Map.put(:reference, reference)

    {:ok, workflow} = Workflows.create_workflow(workflow_params)
    {:ok, response_status} = WorkflowStep.start_next_step(workflow)

    conn
    |> json(%{
      status: response_status,
      workflow_id: workflow.id
    })
  end

  def create_specific(conn, %{"identifier" => "acs"} = params) do
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

  def get(conn, %{"identifier" => workflow_identifier, "reference" => reference}) do
    workflow =
      case workflow_identifier do
        "ebu_ingest" ->
          ExBackend.Workflow.Definition.EbuIngest.get_definition(
            "#agent_identifier",
            "#input_filename"
          )

        "francetv_subtil_rdf_ingest" ->
          mp4_paths =
            ExVideoFactory.get_ftp_paths_for_video_id(reference)
            |> Enum.filter(fn path ->
              String.contains?(path, "-standard5.mp4") ||
                String.contains?(path, "-qad.mp4") ||
                String.contains?(path, "-qaa.mp4")
            end)
            |> Enum.map(fn path -> String.replace(path, "/343079/http", "") end)

          ttml_path =
            ExVideoFactory.get_http_url_for_ttml(reference)
            |> List.first()

          ExBackend.Workflow.Definition.FrancetvSubtilRdfIngest.get_definition(
            mp4_paths,
            ttml_path
          )

        "francetv_subtil_dash_ingest" ->
          ExBackend.Workflow.Definition.FrancetvSubtilDashIngest.get_definition(
            "#mp4_paths",
            "#ttml_path"
          )

        "francetv_subtil_acs" ->
          ExBackend.Workflow.Definition.FrancetvSubtilAcs.get_definition(
            "#source_mp4_path",
            "#source_ttml_path",
            nil
          )

        "ftv_studio_rosetta" ->
          upload_pattern =
            ExBackend.Workflow.Definition.FtvStudioRosetta.get_output_filename_base(reference)

          mp4_paths =
            ExVideoFactory.get_ftp_paths_for_video_id(reference)
            |> Enum.filter(fn path -> String.contains?(path, "-standard5.mp4") end)
            |> Enum.map(fn path -> String.replace(path, "/343079/http", "") end)

          ttml_path =
            ExVideoFactory.get_http_url_for_ttml(reference)
            |> List.first()

          ExBackend.Workflow.Definition.FtvStudioRosetta.get_definition(
            mp4_paths,
            ttml_path,
            upload_pattern
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
end
