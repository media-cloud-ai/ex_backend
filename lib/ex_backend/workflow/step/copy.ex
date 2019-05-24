defmodule ExBackend.Workflow.Step.Copy do
  alias ExBackend.Jobs
  alias ExBackend.Amqp.CommonEmitter
  alias ExBackend.Workflow.Step.Requirements

  @action_name "copy"

  def launch(workflow, step) do
    step_id = ExBackend.Map.get_by_key_or_atom(step, :id)

    case Requirements.get_source_files(workflow.jobs, step) do
      [] ->
        Jobs.create_skipped_job(
          workflow,
          step_id,
          @action_name
        )

      paths ->
        start_to_process_files(paths, workflow, step, step_id)
    end
  end

  def start_to_process_files([], _workflow, _step, _step_id), do: {:ok, "started"}

  def start_to_process_files([path | paths], workflow, step, step_id) do
    requirements = Requirements.add_required_paths(path)

    parameters =
      ExBackend.Map.get_by_key_or_atom(step, :parameters)
      |> Requirements.parse_parameters(workflow)

    output_directory =
      parameters
      |> Enum.filter(fn param ->
        ExBackend.Map.get_by_key_or_atom(param, :id) == "output_directory"
      end)
      |> Enum.map(fn param -> ExBackend.Map.get_by_key_or_atom(param, :value) end)

    destination_path = Path.join(output_directory, Path.basename(path))

    parameters =
      parameters ++
        [
          %{
            "id" => "action",
            "type" => "string",
            "value" => @action_name
          },
          %{
            "id" => "requirements",
            "type" => "requirements",
            "value" => requirements
          },
          %{
            "id" => "source_paths",
            "type" => "paths",
            "value" => [path]
          },
          %{
            "id" => "destination_path",
            "type" => "string",
            "value" => destination_path
          }
        ]

    job_params = %{
      name: @action_name,
      step_id: ExBackend.Map.get_by_key_or_atom(step, :id),
      workflow_id: workflow.id,
      params: %{list: parameters}
    }

    {:ok, job} = Jobs.create_job(job_params)

    params = %{
      job_id: job.id,
      parameters: job.params.list
    }

    case CommonEmitter.publish_json("job_file_system", params) do
      :ok -> start_to_process_files(paths, workflow, step, step_id)
      _ -> {:error, "unable to publish message"}
    end
  end
end
