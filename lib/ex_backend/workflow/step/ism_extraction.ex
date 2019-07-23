defmodule ExBackend.Workflow.Step.IsmExtraction do
  alias ExBackend.Jobs
  alias ExBackend.Amqp.CommonEmitter
  alias ExBackend.Workflow.Step.Requirements

  require Logger

  @action_name "ism_extraction"

  def launch(workflow, step) do
    step_id = ExBackend.Map.get_by_key_or_atom(step, :id)

    paths =
      case ExBackend.Map.get_by_key_or_atom(step, :inputs) do
        nil ->
          Requirements.get_source_files(workflow.jobs, step)
          |> case do
            nil ->
              nil
            [] ->
              nil
            [nil] ->
              nil
            paths ->
              paths
          end

        inputs ->
          inputs
      end

    case paths do
      nil ->
        Jobs.create_skipped_job(workflow, step_id, @action_name)
      paths ->
        video_path =
          Enum.find(paths, fn path -> String.ends_with?(path, ".ismv") end)
        audio_path =
          Enum.find(paths, fn path -> String.ends_with?(path, ".isma") end)

        case {video_path, audio_path} do
          {nil, _} ->
            Jobs.create_skipped_job(workflow, step_id, @action_name)
          {_, nil} ->
            Jobs.create_skipped_job(workflow, step_id, @action_name)
          {video_path, audio_path} ->
            start_extracting_ism(video_path, audio_path, workflow, step, step_id)
        end
    end
  end

  defp start_extracting_ism(video_path, audio_path, workflow, step, step_id) do
    work_dir = System.get_env("WORK_DIR") || Application.get_env(:ex_backend, :work_dir)

    filename = Path.basename(video_path, ".ismv")
    output_extension = ".mp4"

    dst_path =
      work_dir <>
        "/" <>
        Integer.to_string(workflow.id) <>
        "/" <> filename <> output_extension

    requirements = Requirements.add_required_paths(video_path)
    requirements = Requirements.add_required_paths(audio_path, requirements)

    parameters =
      ExBackend.Map.get_by_key_or_atom(step, :parameters, []) ++
        [
          %{
            "id" => "source_paths",
            "type" => "array_of_strings",
            "value" => [video_path, audio_path]
          },
          %{
            "id" => "destination_paths",
            "type" => "array_of_strings",
            "value" => [dst_path]
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
