defmodule ExBackend.Workflow.Step.AcsSynchronize do
  alias ExBackend.Jobs
  alias ExBackend.Amqp.CommonEmitter
  alias ExBackend.Workflow.Step.Requirements

  require Logger

  @action_name "acs_synchronize"

  def launch(workflow, step) do
    step_id = ExBackend.Map.get_by_key_or_atom(step, :id)

    case Requirements.get_source_files(workflow.jobs, step) do
      [path1, path2] ->
        if String.ends_with?(path1, ".mp4") do
          start_processing_synchro(path1, path2, workflow, step, step_id)
        else
          start_processing_synchro(path2, path1, workflow, step, step_id)
        end
      _ ->
        Jobs.create_skipped_job(workflow, step_id, @action_name)
    end
  end

  defp start_processing_synchro(audio_path, subtitle_path, workflow, step, step_id) do
    work_dir =
      System.get_env("WORK_DIR") || Application.get_env(:ex_backend, :work_dir)

    app_dir = System.get_env("APP_DIR") || Application.get_env(:ex_backend, :appdir) || "/opt/app"
    acs_app = System.get_env("ACS_APP") || Application.get_env(:ex_backend, :acs_app)

    filename =
      Path.basename(subtitle_path)
      |> String.replace(".ttml", "_synchronized.ttml")

    dst_path = work_dir <> "/" <> Integer.to_string(workflow.id) <> "/" <> filename

    exec_dir = app_dir <> "/acs"

    requirements = Requirements.add_required_paths([audio_path, subtitle_path])

    parameters =
      ExBackend.Map.get_by_key_or_atom(step, :parameters) ++ [
        %{
          "id" => "source_paths",
          "type" => "paths",
          "value" => [audio_path, subtitle_path]
        },
        %{
          "id" => "destination_path",
          "type" => "string",
          "value" => dst_path
        },
        %{
          "id" => "requirements",
          "type" => "requirements",
          "value" => requirements
        },
        %{
          "id" => "program",
          "type" => "string",
          "value" => acs_app
        },
        %{
          "id" => "exec_dir",
          "type" => "string",
          "value" => exec_dir
        },
        %{
          "id" => "libraries",
          "type" => "paths",
          "value" => [exec_dir]
        }
      ]

    job_params = %{
      name: @action_name,
      step_id: step_id,
      workflow_id: workflow.id,
      params: %{list: parameters}
    }

    {:ok, job} = Jobs.create_job(job_params)

    params = %{
      job_id: job.id,
      parameters: job.params.list
    }

    case CommonEmitter.publish_json("job_acs", params) do
      :ok -> {:ok, "started"}
      _ -> {:error, "unable to publish message"}
    end
  end
end
