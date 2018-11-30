defmodule ExBackend.Workflow.Step.AudioEncode do
  alias ExBackend.Jobs
  alias ExBackend.Amqp.CommonEmitter
  alias ExBackend.Workflow.Step.Requirements

  require Logger

  @action_name "audio_encode"

  def launch(workflow, step) do
    step_id = ExBackend.Map.get_by_key_or_atom(step, :id)

    case get_source_files(workflow.jobs) do
      [] ->
        Jobs.create_skipped_job(
          workflow,
          step_id,
          @action_name
        )

      paths ->
        start_processing_audio(paths, workflow, step_id)
    end
  end

  defp start_processing_audio([], _workflow, _step_id), do: {:ok, "started"}

  defp start_processing_audio([path | paths], workflow, step_id) do
    work_dir = System.get_env("WORK_DIR") || Application.get_env(:ex_backend, :work_dir)

    filename = Path.basename(path, ".wav")

    dst_path =
      work_dir <> "/" <> Integer.to_string(workflow.id) <> "/audio/" <> filename <> ".mp4"

    requirements = Requirements.add_required_paths(path)

    encoding_options = %{
      output_codec_audio: "libfdk_aac",
      profile_audio: "aac_he",
      variable_bitrate: 4,
      force_overwrite: true,
      disable_video: true,
      disable_data: true,
      audio_sampling_rate: 48000,
      audio_channels: 2
    }

    job_params = %{
      name: @action_name,
      step_id: step_id,
      workflow_id: workflow.id,
      params: %{
        requirements: requirements,
        inputs: [
          %{
            path: path,
            options: %{}
          }
        ],
        outputs: [
          %{
            path: dst_path,
            options: encoding_options
          }
        ]
      }
    }

    {:ok, job} = Jobs.create_job(job_params)

    params = %{
      job_id: job.id,
      parameters: job.params
    }

    case CommonEmitter.publish_json("job_ffmpeg", params) do
      :ok -> start_processing_audio(paths, workflow, step_id)
      _ -> {:error, "unable to publish message"}
    end
  end

  defp get_source_files(jobs) do
    # TODO: handle audio_split result
    ExBackend.Workflow.Step.AudioDecode.get_jobs_destination_paths(jobs)
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
          |> Map.get("destination", %{})
          |> Map.get("paths")
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
