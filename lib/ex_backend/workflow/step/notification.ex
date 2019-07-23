defmodule ExBackend.Workflow.Step.Notification do
  alias ExBackend.Jobs
  alias ExBackend.Workflow.Step.Requirements
  alias ExBackend.Workflows

  require Logger

  @action_name "send_notification"

  def launch(workflow, step) do
    parameters =
      ExBackend.Map.get_by_key_or_atom(step, :parameters, [])

    job_params = %{
      name: @action_name,
      step_id: ExBackend.Map.get_by_key_or_atom(step, :id),
      workflow_id: workflow.id,
      params: %{list: parameters}
    }

    {:ok, job} = Jobs.create_job(job_params)

    try do
      case process_notification(workflow, job.id, parameters) do
        {:ok, _} ->
          Jobs.Status.set_job_status(job.id, "completed")
          {:ok, "completed"}

        {:error, message} ->
          Jobs.Status.set_job_status(job.id, "error", %{
            message: "unable to notify: #{message}"
          })
          Workflows.notification_from_job(job.id)

          {:error, message}
      end
    rescue
      error ->
        Logger.error("#{__MODULE__} raised: #{inspect(error)}")
        Jobs.Status.set_job_status(job.id, "error", %{message: "unable to notify"})
        Workflows.notification_from_job(job.id)
        {:error, "unable to notify"}
    end
  end

  def process_notification(workflow, job_id, parameters) do

    status =
      case HTTPotion.get("https://gatewayvf.webservices.francetelevisions.fr/v1/videos?qid=" <> workflow.reference, headers: [accept: "*/*"]) do
        %HTTPotion.Response{body: body, status_code: 200} ->
          source_information =
            body
            |> Jason.decode!
            |> List.first

          id = ExBackend.Map.get_by_key_or_atom(source_information, :id)
          title = ExBackend.Map.get_by_key_or_atom(source_information, :title)
          additional_title = ExBackend.Map.get_by_key_or_atom(source_information, :additional_title)
          duration = ExBackend.Map.get_by_key_or_atom(source_information, :duration)
          expected_duration = ExBackend.Map.get_by_key_or_atom(source_information, :expected_duration)
          expected_at = ExBackend.Map.get_by_key_or_atom(source_information, :expected_at)
          broadcasted_at = ExBackend.Map.get_by_key_or_atom(source_information, :broadcasted_at)
          legacy_id = ExBackend.Map.get_by_key_or_atom(source_information, :legacy_id)
          oscar_id = ExBackend.Map.get_by_key_or_atom(source_information, :oscar_id)
          aedra_id = ExBackend.Map.get_by_key_or_atom(source_information, :aedra_id)
          plurimedia_broadcast_id = ExBackend.Map.get_by_key_or_atom(source_information, :plurimedia_broadcast_id)
          plurimedia_collection_ids = ExBackend.Map.get_by_key_or_atom(source_information, :plurimedia_collection_ids)
          plurimedia_program_id = ExBackend.Map.get_by_key_or_atom(source_information, :plurimedia_program_id)
          ftvcut_id = ExBackend.Map.get_by_key_or_atom(source_information, :ftvcut_id)
          channel =
            ExBackend.Map.get_by_key_or_atom(source_information, :channel)
            |> ExBackend.Map.get_by_key_or_atom(:id)

          case Requirements.get_workflow_step(workflow, job_id) do
            nil -> {:skipped, "skip notification"}
            step ->
              %{
                ttml_path: ttml_path,
                mp4_path: mp4_path
              } = Requirements.get_source_files(workflow.jobs, step)
                  |> split_mp4_and_ttml
              
              body = %{
                id: id,
                title: title,
                additional_title: additional_title,
                duration: duration,
                expected_duration: expected_duration,
                expected_at: expected_at,
                broadcasted_at: broadcasted_at,
                legacy_id: legacy_id,
                oscar_id: oscar_id,
                aedra_id: aedra_id,
                plurimedia_broadcast_id: plurimedia_broadcast_id,
                plurimedia_collection_ids: plurimedia_collection_ids,
                plurimedia_program_id: plurimedia_program_id,
                ftvcut_id: ftvcut_id,
                channel: channel,
                ttml_path: ttml_path,
                mp4_path: mp4_path,
              }

              endpoint = Requirements.get_parameter(parameters, "endpoint")
              token = Requirements.get_parameter(parameters, "token")
              headers = [
                {"Content-Type", "application/json"}
              ]

              headers =
                case token do
                  nil -> headers
                  token ->
                    headers
                    |> Keyword.put_new(:Authorization, "Bearer " <> token)
                end

              if legacy_id && ttml_path && mp4_path do
                case HTTPotion.post(endpoint, [body: body |> Jason.encode!, headers: headers]) do
                  %HTTPotion.Response{status_code: 200} ->
                    {:ok, "completed"}
                  response ->
                    Logger.error('unable to notify #{endpoint}: #{inspect response}')
                    {:error, "unable to notify: #{endpoint}"}
                end
              else
                Logger.info("skip notification")
                {:skipped, "skip notification"}
              end
          end
        _ -> {:error, "unable to get video metadata on FranceTélévisions SI"}
      end

    case status do
      {:ok, _} -> 
        Jobs.Status.set_job_status(job_id, "completed")
        Workflows.notification_from_job(job_id)
        {:ok, "completed"}
      {:skipped, _} -> 
        Jobs.Status.set_job_status(job_id, "skipped")
        Workflows.notification_from_job(job_id)
        {:ok, "skipped"}
      {:error, message} ->
        Jobs.Status.set_job_status(job_id, "error", %{
            message: message
          })
        Workflows.notification_from_job(job_id)
        {:error, message}
    end
  end


  defp split_mp4_and_ttml(source, result \\ %{ttml_path: nil, mp4_path: nil})
  defp split_mp4_and_ttml([], result), do: result
  defp split_mp4_and_ttml([source | sources], %{ttml_path: ttml_path, mp4_path: mp4_path}) do
    ttml_path =
      if String.ends_with?(source, ".ttml") do
        source
      else
        ttml_path
      end

    mp4_path =
      if String.ends_with?(source, ".mp4") do
        source
      else
        mp4_path
      end

    split_mp4_and_ttml(sources, %{ttml_path: ttml_path, mp4_path: mp4_path})

  end
end
