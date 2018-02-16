defmodule ExSubtilBackend.Workflow.Step.GenerateDash do

  alias ExSubtilBackend.Jobs
  alias ExSubtilBackend.Amqp.JobGpacEmitter

  def launch(workflow, step) do
    paths = get_ftp_downloaded_path(workflow.jobs, [])

    options = %{
      "-out": "/tmp/ftp_ftv/dash/" <> workflow.reference
    }

    options =
      Map.get(step, "parameters", [])
      |> build_gpac_parameters(options)

    job_params = %{
      name: "generate_dash",
      workflow_id: workflow.id,
      params: %{
        source: %{
          paths: paths
        },
        options: options
      }
    }

    {:ok, job} = Jobs.create_job(job_params)
    params = %{
      job_id: job.id,
      parameters: job.params
    }
    JobGpacEmitter.publish_json(params)
  end

  defp get_ftp_downloaded_path([], result), do: result
  defp get_ftp_downloaded_path([job | jobs], result) do
    result =
      case job.name do
        "download_ftp" ->
          path =
            job.params
            |> Map.get("destination")
            |> Map.get("path")

          List.insert_at(result, -1, path)
        _ -> result
      end

    get_ftp_downloaded_path(jobs, result)
  end

  defp build_gpac_parameters([], result), do: result
  defp build_gpac_parameters([param | params], result) do
    key =
      Map.get(param, "id")
      |> convert_gpac_key

    value = Map.get(param, "value")

    result = Map.put(result, key, value)
    build_gpac_parameters(params, result)
  end

  defp convert_gpac_key("segment_duration"), do: "-dash"
  defp convert_gpac_key("fragment_duration"), do: "-frag"
  defp convert_gpac_key(_), do: nil
end
