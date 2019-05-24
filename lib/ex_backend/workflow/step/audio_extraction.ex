defmodule ExBackend.Workflow.Step.AudioExtraction do
  alias ExBackend.Jobs
  alias ExBackend.Amqp.CommonEmitter
  alias ExBackend.Workflow.Step.Requirements

  require Logger

  @action_name "audio_extraction"

  def launch(workflow, step) do
    step_id = ExBackend.Map.get_by_key_or_atom(step, :id)

    case ExBackend.Map.get_by_key_or_atom(step, :inputs) do
      nil ->
        Requirements.get_source_files(workflow.jobs, step)
        |> case do
          nil -> Jobs.create_skipped_job(workflow, step_id, @action_name)
          [] -> Jobs.create_skipped_job(workflow, step_id, @action_name)
          [nil] -> Jobs.create_skipped_job(workflow, step_id, @action_name)
          path -> start_extracting_audio(path, workflow, step, step_id)
        end

      inputs ->
        for input <- inputs do
          {:ok, "started"} =
            start_extracting_audio(
              ExBackend.Map.get_by_key_or_atom(input, :path),
              workflow,
              step,
              step_id
            )
        end

        {:ok, "started"}
    end
  end

  defp start_extracting_audio([], _workflow, _step, _step_id), do: {:ok, "started"}

  defp start_extracting_audio([path | paths], workflow, step, step_id) do
    case start_extracting_audio(path, workflow, step, step_id) do
      {:ok, "started"} -> start_extracting_audio(paths, workflow, step, step_id)
      {:error, message} -> {:error, message}
    end
  end

  defp start_extracting_audio(path, workflow, step, step_id) do
    work_dir = System.get_env("WORK_DIR") || Application.get_env(:ex_backend, :work_dir)

    filename = Path.basename(path)

    output_extension =
      ExBackend.Map.get_by_key_or_atom(step, :parameters)
      |> Enum.filter(fn param ->
        ExBackend.Map.get_by_key_or_atom(param, :id) == "output_extension"
      end)
      |> Enum.map(fn param -> ExBackend.Map.get_by_key_or_atom(param, :value) end)
      |> case do
        [ext] -> ext
        _ -> "-fra.mp4"
      end

    dst_path =
      work_dir <>
        "/" <>
        Integer.to_string(workflow.id) <>
        "/" <> Integer.to_string(step_id) <> "_" <> filename <> output_extension

    requirements = Requirements.add_required_paths(path)

    parameters =
      ExBackend.Map.get_by_key_or_atom(step, :parameters, []) ++
        [
          %{
            "id" => "source_path",
            "type" => "string",
            "value" => path
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

    case CommonEmitter.publish_json("job_ffmpeg", params) do
      :ok -> {:ok, "started"}
      _ -> {:error, "unable to publish message"}
    end
  end
end
