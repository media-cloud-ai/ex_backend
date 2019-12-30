defmodule ExBackendWeb.WorkflowController do
  use ExBackendWeb, :controller
  require Logger

  import ExBackendWeb.Authorize

  alias StepFlow.Workflows
  alias StepFlow.Step

  action_fallback(ExBackendWeb.FallbackController)

  # the following plugs are defined in the controllers/authorize.ex file
  plug(:user_check when action in [:create_specific, :get])

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
      ExBackend.Workflow.Definition.FrancetvAcs.get_definition(
        audio_url,
        ttml_url,
        destination_url
      )
      |> Map.put(:reference, reference)

    {:ok, workflow} = Workflows.create_workflow(workflow_params)
    {:ok, response_status} = Step.start_next(workflow)

    conn
    |> json(%{
      status: response_status,
      workflow_id: workflow.id
    })
  end

  def create_specific(conn, %{
        "identifier" => "ftv-acs-standalone",
        "reference" => reference
      }) do
    ism_source_path =
      ExVideoFactory.get_ftp_paths_for_video_id(reference)
      |> Enum.filter(fn path -> String.contains?(path, ".ism") end)
      |> List.first()

    mp4_source_path =
      ExVideoFactory.get_ftp_paths_for_video_id(reference)
      |> Enum.filter(fn path -> String.contains?(path, "-standard5.mp4") end)
      |> List.first()
      |> String.replace("/343079/http/", "/")

    ttml_source_path =
      ExVideoFactory.get_http_url_for_ttml(reference)
      |> List.first()

    workflow_params =
      ExBackend.Workflow.Definition.FrancetvAcs.get_definition(
        ism_source_path,
        mp4_source_path,
        ttml_source_path
      )
      |> Map.put(:reference, reference)

    {:ok, workflow} = Workflows.create_workflow(workflow_params)
    {:ok, response_status} = Step.start_next(workflow)

    conn
    |> json(%{
      status: response_status,
      workflow_id: workflow.id
    })
  end

  def create_specific(conn, %{
        "identifier" => "speech_to_text",
        "source_filename" => audio_source_filename,
        "content_type" => content_type,
        "language" => language
      }) do
    workflow_params =
      ExBackend.Workflow.Definition.FrancetvSpeechToText.get_definition()
      |> Map.put(:reference, audio_source_filename)
      |> Map.put(:parameters, [
        %{
          id: "audio_source_filename",
          type: "string",
          value: audio_source_filename
        },
        %{
          id: "content_type",
          type: "string",
          value: content_type
        },
        %{
          id: "language",
          type: "string",
          value: language
        }
      ])

    {:ok, workflow} = Workflows.create_workflow(workflow_params)
    {:ok, response_status} = Step.start_next(workflow)

    conn
    |> json(%{
      status: response_status,
      workflow_id: workflow.id
    })
  end

  def create_specific(conn, %{
        "identifier" => "ftv_dialog_enhancement",
        "source_filename" => source_filename,
        "dialog_gain" => dialog_gain,
        "ambiance_gain" => ambiance_gain
      }) do
    workflow_params =
      ExBackend.Workflow.Definition.FrancetvDialogEnhancement.get_definition()
      |> Map.put(:reference, source_filename)
      |> Map.put(:parameters, [
        %{
          id: "source_filename",
          type: "string",
          value: source_filename
        },
        %{
          id: "dialog_gain",
          type: "string",
          value: dialog_gain
        },
        %{
          id: "ambiance_gain",
          type: "string",
          value: ambiance_gain
        }
      ])

    {:ok, workflow} = Workflows.create_workflow(workflow_params)
    {:ok, response_status} = Step.start_next(workflow)

    conn
    |> json(%{
      status: response_status,
      workflow_id: workflow.id
    })
  end

  def create_specific(conn, %{"identifier" => "ftv-acs-standalone"} = _params) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{
      status: "error",
      message: "missing parameters to start acs workflow"
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

  def create_specific(conn, %{"identifier" => "speech_to_text"} = _params) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{
      status: "error",
      message: "missing parameters to start speech_to_text workflow"
    })
  end

  def create_specific(conn, %{"identifier" => "ftv_dialog_enhancement"} = _params) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{
      status: "error",
      message: "missing parameters to start ftv_dialog_enhancement workflow"
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

  def get(conn, %{"identifier" => workflow_identifier} = params) do
    workflow =
      case workflow_identifier do
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
