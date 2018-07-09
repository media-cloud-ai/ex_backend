defmodule ExBackend.WorkflowStep do
  @moduledoc """
  The Workflow Step context.
  """

  require Logger

  alias ExBackend.Workflows.Workflow
  alias ExBackend.Artifacts

  def start_next_step(%Workflow{id: workflow_id} = workflow) do
    workflow = ExBackend.Repo.preload(workflow, :jobs, force: true)

    step_index =
      Enum.map(workflow.jobs, fn job -> job.name end)
      |> Enum.uniq()
      |> length

    steps =
      workflow.flow
      |> Map.get("steps")

    case Enum.at(steps, step_index) do
      nil ->
        set_artifacts(workflow)
        Logger.warn("#{__MODULE__}: workflow #{workflow_id} is completed")

      step ->
        Logger.warn(
          "#{__MODULE__}: start to process step #{step["name"]} (index #{step_index}) for workflow #{
            workflow_id
          }"
        )

        status = launch_step(workflow, step, step_index)

        topic = "update_workflow_" <> Integer.to_string(workflow_id)

        ExBackendWeb.Endpoint.broadcast!("notifications:all", topic, %{
          body: %{workflow_id: workflow_id}
        })

        case status do
          {:ok, "skipped"} -> start_next_step(workflow)
          {:ok, "completed"} -> start_next_step(workflow)
          _ -> status
        end
    end
  end

  def skip_step(workflow, step) do
    step_name = Map.get(step, "name")

    ExBackend.Repo.preload(workflow, :jobs, force: true)
    |> ExBackend.Jobs.create_skipped_job(step_name)
  end

  def skip_step_jobs(workflow, step) do
    step_name = Map.get(step, "name")

    ExBackend.Repo.preload(workflow, :jobs, force: true)
    |> ExBackend.Jobs.skip_jobs(step_name)
  end

  defp launch_step(workflow, %{"name" => "download_ftp"} = _step, _step_index) do
    ExBackend.Workflow.Step.FtpDownload.launch(workflow)
  end

  defp launch_step(workflow, %{"name" => "download_http"} = _step, _step_index) do
    ExBackend.Workflow.Step.HttpDownload.launch(workflow)
  end

  defp launch_step(workflow, %{"name" => "audio_decode"} = _step, _step_index) do
    ExBackend.Workflow.Step.AudioDecode.launch(workflow)
  end

  defp launch_step(workflow, %{"name" => "acs_prepare_audio"} = _step, _step_index) do
    ExBackend.Workflow.Step.Acs.PrepareAudio.launch(workflow)
  end

  defp launch_step(workflow, %{"name" => "acs_synchronize"} = step, _step_index) do
    ExBackend.Workflow.Step.Acs.Synchronize.launch(workflow, step)
  end

  defp launch_step(workflow, %{"name" => "audio_encode"} = _step, _step_index) do
    ExBackend.Workflow.Step.AudioEncode.launch(workflow)
  end

  defp launch_step(workflow, %{"name" => "ttml_to_mp4"} = _step, _step_index) do
    ExBackend.Workflow.Step.TtmlToMp4.launch(workflow)
  end

  defp launch_step(workflow, %{"name" => "audio_extraction"} = _step, _step_index) do
    ExBackend.Workflow.Step.AudioExtraction.launch(workflow)
  end

  defp launch_step(workflow, %{"name" => "set_language"} = step, _step_index) do
    ExBackend.Workflow.Step.SetLanguage.launch(workflow, step)
  end

  defp launch_step(workflow, %{"name" => "generate_dash"} = step, _step_index) do
    ExBackend.Workflow.Step.GenerateDash.launch(workflow, step)
  end

  defp launch_step(workflow, %{"name" => "upload_ftp"} = step, _step_index) do
    ExBackend.Workflow.Step.FtpUpload.launch(workflow, step)
  end

  defp launch_step(workflow, %{"name" => "push_rdf"} = _step, _step_index) do
    ExBackend.Workflow.Step.PushRdf.launch(workflow)
  end

  defp launch_step(workflow, %{"name" => "clean_workspace"} = _step, _step_index) do
    ExBackend.Workflow.Step.CleanWorkspace.launch(workflow)
  end

  defp launch_step(workflow, step, _step_index) do
    Logger.error("unable to match with the step #{inspect(step)} for workflow #{workflow.id}")
    {:error, "unable to match with the step #{inspect(step)}"}
  end

  def set_artifacts(workflow) do
    paths =
      get_uploaded_file_path(workflow.jobs)
      |> Enum.filter(fn path -> String.ends_with?(path, ".mpd") end)

    resources =
      case paths do
        [] -> %{}
        paths -> %{manifest: List.first(paths)}
      end

    params = %{
      resources: resources,
      workflow_id: workflow.id
    }

    Artifacts.create_artifact(params)
  end

  def get_uploaded_file_path(jobs, result \\ [])
  def get_uploaded_file_path([], result), do: result

  def get_uploaded_file_path([job | jobs], result) do
    result =
      if job.name == "upload_ftp" do
        path =
          job
          |> Map.get(:params, %{})
          |> Map.get("destination", %{})
          |> Map.get("path")

        case path do
          nil -> result
          path -> List.insert_at(result, -1, path)
        end
      else
        result
      end

    get_uploaded_file_path(jobs, result)
  end
end
