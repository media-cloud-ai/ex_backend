defmodule ExBackend.Workflow.Step.CleanWorkspace do
  alias ExBackend.Jobs
  alias ExBackend.Amqp.CommonEmitter
  alias ExBackend.Workflow.Step.Requirements

  @action_name "clean_workspace"

  def launch(workflow) do
    workflow
    |> ExBackend.Map.get_by_key_or_atom(:flow)
    |> ExBackend.Map.get_by_key_or_atom(:steps)
    |> Enum.filter(fn step ->
      ExBackend.Map.get_by_key_or_atom(step, :name) == @action_name
    end)
    |> Enum.map(fn step ->
      launch(workflow, step)
    end)
  end

  def launch(workflow, step) do
    if has_local_folder(workflow.jobs) do
      work_dir = System.get_env("WORK_DIR") || Application.get_env(:ex_backend, :work_dir)
      dst_path = work_dir <> "/" <> Integer.to_string(workflow.id)

      requirements = Requirements.add_required_paths([dst_path])

      job_params = %{
        name: @action_name,
        step_id: ExBackend.Map.get_by_key_or_atom(step, :id),
        workflow_id: workflow.id,
        params: %{
          list: [
            %{
              "id" => "action",
              "type" => "string",
              "value" => "remove"
            },
            %{
              "id" => "requirements",
              "type" => "requirements",
              "value" => requirements
            },
            %{
              "id" => "source_path",
              "type" => "string",
              "value" => dst_path
            }
          ]
        }
      }

      {:ok, job} = Jobs.create_job(job_params)

      params = %{
        job_id: job.id,
        parameters: job.params.list
      }

      case CommonEmitter.publish_json("job_file_system", params) do
        :ok -> {:ok, "started"}
        _ -> {:error, "unable to publish message"}
      end
    else
      Jobs.create_skipped_job(
        workflow,
        ExBackend.Map.get_by_key_or_atom(step, :id),
        @action_name
      )
    end
  end

  @doc """
  Returns true if any job have a destination_path (which means it use storage to process workflow)
  """
  def has_local_folder([]), do: false
  def has_local_folder([job | jobs]) do
    destinations =
      job.params
      |> Map.get("destination", %{})
      |> Map.get("paths")

    destination_paths =
      job.params
      |> Map.get("list", [])
      |> Enum.filter(fn param ->
        ExBackend.Map.get_by_key_or_atom(param, :id) == "destination_path"
      end)
      |> Enum.map(fn param ->
        ExBackend.Map.get_by_key_or_atom(param, :value)
      end)

    if destinations == nil && destination_paths == [] do
      has_local_folder(jobs)
    else
      true
    end
  end
end
