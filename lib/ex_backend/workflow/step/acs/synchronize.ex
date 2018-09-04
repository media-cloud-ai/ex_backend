defmodule ExBackend.Workflow.Step.Acs.Synchronize do
  alias ExBackend.Jobs
  alias ExBackend.Amqp.JobAcsEmitter
  alias ExBackend.Workflow.Step.Requirements

  require Logger

  @action_name "acs_synchronize"

  def launch(workflow, step) do
    source_files = get_source_files(workflow.jobs)

    case map_size(source_files) do
      0 -> Jobs.create_skipped_job(workflow, ExBackend.Map.get_by_key_or_atom(step, :id), @action_name)
      _ -> start_processing_synchro(source_files, workflow, step)
    end
  end

  defp start_processing_synchro(
         %{audio_path: audio_path, subtitle_path: subtitle_path},
         workflow,
         step
       ) do
    work_dir =
      System.get_env("WORK_DIR") || Application.get_env(:ex_backend, :work_dir) ||
        "/tmp/ftp_francetv"

    app_dir = System.get_env("APP_DIR") || Application.get_env(:ex_backend, :appdir) || "/opt/app"

    acs_app = System.get_env("ACS_APP") || Application.get_env(:ex_backend, :acs_app)

    filename =
      Path.basename(subtitle_path)
      |> String.replace(".ttml", "_synchronized.ttml")

    dst_path =
      work_dir <>
        "/" <> workflow.reference <> "_" <> Integer.to_string(workflow.id) <> "/acs/" <> filename

    exec_dir = app_dir <> "/acs"

    requirements = Requirements.add_required_paths([audio_path, subtitle_path])

    threads_number =
      Map.get(step, "parameters", [])
      |> Enum.find(fn param -> Map.get(param, "id") == "threads_number" end)
      |> case do
        nil -> 8
        threads_param -> Map.get(threads_param, "value")
      end
      |> Integer.to_string()

    job_params = %{
      name: @action_name,
      workflow_id: workflow.id,
      params: %{
        requirements: requirements,
        program: acs_app,
        exec_dir: exec_dir,
        libraries: [
          exec_dir
        ],
        inputs: [
          %{
            path: audio_path,
            options: %{}
          },
          %{
            path: subtitle_path,
            options: %{}
          }
        ],
        outputs: [
          %{
            path: dst_path,
            options: %{}
          },
          %{
            options: %{
              threads_number => true
            }
          }
        ]
      }
    }

    {:ok, job} = Jobs.create_job(job_params)

    params = %{
      job_id: job.id,
      parameters: job.params
    }

    JobAcsEmitter.publish_json(params)
  end

  defp get_source_files(jobs) do
    audio_path =
      ExBackend.Workflow.Step.Acs.PrepareAudio.get_jobs_destination_paths(jobs)
      |> List.first()

    subtitle_path =
      ExBackend.Workflow.Step.HttpDownload.get_jobs_destination_paths(jobs)
      |> List.first()

    cond do
      is_nil(audio_path) ->
        %{}

      is_nil(subtitle_path) ->
        %{}

      true ->
        %{
          audio_path: audio_path,
          subtitle_path: subtitle_path
        }
    end
  end

  @doc """
  Returns the list of destination paths of this workflow step
  """
  def get_jobs_destination_paths(_jobs, steps, result \\ [])
  def get_jobs_destination_paths([], _steps, result), do: result

  def get_jobs_destination_paths([job | jobs], steps, result) do
    result =
      case job.name do
        @action_name ->
          paths =
            job.params
            |> Map.get("destination", %{})
            |> Map.get("paths")
            |> case do
              nil -> result
              paths -> Enum.concat(paths, result)
            end

          case Enum.find(steps, fn step -> Map.get(step, "name") == @action_name end) do
            nil ->
              paths

            step ->
              keep_original =
                step
                |> Map.get("parameters", [])
                |> Enum.any?(fn param ->
                  Map.get(param, "id") == "keep_original" && Map.get(param, "value") == true
                end)

              if keep_original do
                job.params
                |> Map.get("inputs", [])
                |> Enum.find(fn input ->
                  Map.get(input, "path", "")
                  |> String.ends_with?(".ttml")
                end)
                |> case do
                  nil -> paths
                  input -> List.insert_at(paths, -1, Map.get(input, "path"))
                end
              else
                paths
              end
          end

        _ ->
          result
      end

    get_jobs_destination_paths(jobs, steps, result)
  end
end
