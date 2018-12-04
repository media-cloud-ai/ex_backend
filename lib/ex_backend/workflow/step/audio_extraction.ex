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
        get_first_source_file(workflow.jobs, step)
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

  defp start_extracting_audio(path, workflow, step, step_id) do
    work_dir = System.get_env("WORK_DIR") || Application.get_env(:ex_backend, :work_dir)

    filename = Path.basename(path)

    output_extension =
      case ExBackend.Map.get_by_key_or_atom(step, :output_extension) do
        nil -> "-fra.mp4"
        ext -> ext
      end

    dst_path =
      work_dir <>
        "/" <>
        Integer.to_string(workflow.id) <>
        "/" <> Integer.to_string(step_id) <> "_" <> filename <> output_extension

    requirements = Requirements.add_required_paths(path)

    parameters =
      ExBackend.Map.get_by_key_or_atom(step, :parameters, []) ++ [
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
        },
        %{
          "id" => "output_codec_audio",
          "type" => "string",
          "value" => "copy"
        },
        %{
          "id" => "force_overwrite",
          "type" => "boolean",
          "value" => true
        },
        %{
          "id" => "disable_video",
          "type" => "boolean",
          "value" => true
        },
        %{
          "id" => "disable_data",
          "type" => "boolean",
          "value" => true
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

  defp get_first_source_file(jobs, step) do
    ftp_files =
      ExBackend.Workflow.Step.Requirements.get_source_files(jobs, step)
      |> Enum.find(fn path -> String.ends_with?(path, "-standard1.mp4") end)

    case ftp_files do
      nil -> ExBackend.Workflow.Step.UploadFile.get_jobs_destination_paths(jobs)
      filename -> filename
    end
  end

  @doc """
  Returns the list of destination paths of this workflow step
  """
  def get_jobs_destination_paths(_jobs, result \\ [])
  def get_jobs_destination_paths([], result), do: result

  def get_jobs_destination_paths([job | jobs], result) do
    result =
      case job.name do
        @action_name ->
          job.params
          |> ExBackend.Map.get_by_key_or_atom(:destination, %{})
          |> ExBackend.Map.get_by_key_or_atom(:paths)
          |> case do
            nil -> result
            paths -> Enum.concat(paths, result)
          end

        _ ->
          result
      end

    get_jobs_destination_paths(jobs, result)
  end
end
