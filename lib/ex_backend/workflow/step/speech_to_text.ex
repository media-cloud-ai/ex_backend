defmodule ExBackend.Workflow.Step.SpeechToText do
  alias ExBackend.Jobs
  alias ExBackend.Amqp.JobSpeechToTextEmitter
  alias ExBackend.Workflow.Step.Requirements

  require Logger

  @action_name "speech_to_text"

  def launch(workflow, step) do
    step_id = ExBackend.Map.get_by_key_or_atom(step, :id)
    case ExBackend.Map.get_by_key_or_atom(step, :inputs) do
      nil ->
        case get_first_source_file(workflow.jobs, step) do
          nil -> Jobs.create_skipped_job(workflow, step_id, @action_name)
          [] -> Jobs.create_skipped_job(workflow, step_id, @action_name)
          paths ->
            paths
            |> Enum.map(fn path -> start_speech_to_text(path, workflow, step) end)

            {:ok, "started"}
        end

      inputs ->
        inputs
        |> Enum.map(fn input ->
          start_speech_to_text(ExBackend.Map.get_by_key_or_atom(input, :path), workflow, step)
        end)
        {:ok, "started"}
    end
  end

  defp start_speech_to_text(path, workflow, step) do
    work_dir =
      System.get_env("WORK_DIR") || Application.get_env(:ex_backend, :work_dir)

    dst_path =
      work_dir <>
        "/" <> Integer.to_string(workflow.id) <> "/" <> (path |> Path.basename) <> ".vtt"

    requirements = Requirements.add_required_paths(path)

    job_params = %{
      name: @action_name,
      step_id: ExBackend.Map.get_by_key_or_atom(step, :id),
      workflow_id: workflow.id,
      params: %{
        requirements: requirements,
        language: "en-US",
        format: "detailed",
        mode: "conversation",
        inputs: [
          %{
            path: path
          }
        ],
        outputs: [
          %{
            path: dst_path
          }
        ]
      }
    }

    {:ok, job} = Jobs.create_job(job_params)

    params = %{
      job_id: job.id,
      parameters: job.params
    }

    JobSpeechToTextEmitter.publish_json(params)
    {:ok, "started"}
  end

  defp get_first_source_file(jobs, step) do
    parent_ids = ExBackend.Map.get_by_key_or_atom(step, :parent_ids, [])

    jobs
    |> Enum.filter(fn job ->
      job.step_id in parent_ids
    end)
    |> Enum.map(fn job ->
      job
      |> Map.get(:params)
      |> Map.get("outputs")
      |> Enum.map(fn output -> Map.get(output, "path") end)
    end)
    |> List.flatten
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
