defmodule ExBackend.Workflow.Definition.FtvStudioRosetta do
  def get_output_filename_base(video_id) do
    video =
      ExVideoFactory.videos(%{"qid" => video_id})
      |> Map.get(:videos)
      |> List.first()

    {title, _} =
      case Map.get(video, "title") do
        nil -> ""
        value -> value
      end
      |> :unicode.characters_to_nfd_binary()
      |> String.replace(~r/[^A-z0-9-\s]/u, "")
      |> String.replace(~r/\s/, "-")
      |> String.split_at(47)

    {additional_title, _} =
      case Map.get(video, "additional_title") do
        nil -> ""
        value -> value
      end
      |> :unicode.characters_to_nfd_binary()
      |> String.replace(~r/[^A-z0-9-\s]/u, "")
      |> String.replace(~r/\s/, "-")
      |> String.split_at(47)

    broadcasted_at =
      Map.get(video, "broadcasted_at")
      |> format_broadcasted_at()

    channel =
      case Map.get(video, "channel") do
        nil ->
          "XX"

        value ->
          value
          |> Map.get("id")
          |> format_channel()
      end

    "#{channel}/#{title}/#{channel}_#{broadcasted_at}_#{title}_#{additional_title}#input_extension"
  end

  defp format_broadcasted_at(nil) do
    "00000000_0000"
  end

  defp format_broadcasted_at(date) do
    {:ok, date_object} = Timex.parse(date, "%Y-%m-%dT%H:%M:%S", :strftime)
    {:ok, broadcasted_at} = Timex.format(date_object, "%Y%m%d_%H%M", :strftime)
    broadcasted_at
  end

  defp format_channel("france-2") do
    "F2"
  end

  defp format_channel("france-3") do
    "F3"
  end

  defp format_channel("france-4") do
    "F4"
  end

  defp format_channel("france-5") do
    "F5"
  end

  defp format_channel("france-o") do
    "FO"
  end

  defp format_channel("france-info") do
    "FI"
  end

  defp format_channel(_) do
    "XX"
  end

  def get_definition(source_mp4_paths, source_ttml_path, upload_pattern) do
    source_ttml_paths =
      case source_ttml_path do
        nil -> []
        path -> [path]
      end

    %{
      identifier: "FranceTV Studio Ingest Rosetta",
      version_major: 0,
      version_minor: 0,
      version_micro: 0,
      tags: ["francetv", "studio", "rosetta", "ingest"],
      flow: %{
        steps: [
          %{
            id: 0,
            name: "download_ftp",
            enable: true,
            parameters: [
              %{
                id: "source_paths",
                type: "array_of_strings",
                enable: true,
                default: source_mp4_paths,
                value: source_mp4_paths
              },
              %{
                id: "source_hostname",
                type: "credential",
                default: "AKAMAI_REPLAY_HOSTNAME",
                value: "AKAMAI_REPLAY_HOSTNAME"
              },
              %{
                id: "source_username",
                type: "credential",
                default: "AKAMAI_REPLAY_USERNAME",
                value: "AKAMAI_REPLAY_USERNAME"
              },
              %{
                id: "source_password",
                type: "credential",
                default: "AKAMAI_REPLAY_PASSWORD",
                value: "AKAMAI_REPLAY_PASSWORD"
              },
              %{
                id: "source_prefix",
                type: "credential",
                default: "AKAMAI_REPLAY_PREFIX",
                value: "AKAMAI_REPLAY_PREFIX"
              },
              %{
                id: "source_ssl",
                type: "credential",
                default: "AKAMAI_REPLAY_SSL",
                value: "AKAMAI_REPLAY_SSL"
              }
            ]
          },
          %{
            id: 1,
            parent_ids: [0],
            required: [0],
            name: "download_ftp",
            enable: true,
            parameters: [
              %{
                id: "source_paths",
                type: "array_of_strings",
                enable: true,
                default: source_ttml_paths,
                value: source_ttml_paths
              }
            ]
          },
          %{
            id: 2,
            name: "upload_ftp",
            enable: true,
            parent_ids: [0, 1],
            required: [0, 1],
            parameters: [
              %{
                id: "destination_hostname",
                type: "credential",
                default: "FTP_ROSETTA_HOSTNAME",
                value: "FTP_ROSETTA_HOSTNAME"
              },
              %{
                id: "destination_username",
                type: "credential",
                default: "FTP_ROSETTA_USERNAME",
                value: "FTP_ROSETTA_USERNAME"
              },
              %{
                id: "destination_password",
                type: "credential",
                default: "FTP_ROSETTA_PASSWORD",
                value: "FTP_ROSETTA_PASSWORD"
              },
              %{
                id: "destination_prefix",
                type: "credential",
                default: "FTP_ROSETTA_PREFIX",
                value: "FTP_ROSETTA_PREFIX"
              },
              %{
                id: "destination_pattern",
                type: "string",
                default: upload_pattern,
                value: upload_pattern
              },
              %{
                id: "ssl",
                type: "credential",
                default: "FTP_ROSETTA_SSL",
                value: "FTP_ROSETTA_SSL"
              }
            ]
          },
          %{
            id: 3,
            parent_ids: [2],
            required: [2],
            name: "clean_workspace",
            enable: true
          },
          %{
            id: 4,
            parent_ids: [2],
            required: [3],
            name: "send_notification",
            label: "Send notification",
            icon: "notification_important",
            enable: true,
            parameters: [
              %{
                id: "endpoint",
                type: "credential",
                default: "ATTESOR_FTVACCESS_ENDPOINT",
                value: "ATTESOR_FTVACCESS_ENDPOINT"
              },
              %{
                id: "token",
                type: "credential",
                default: "ATTESOR_FTVACCESS_TOKEN",
                value: "ATTESOR_FTVACCESS_TOKEN"
              },
            ]
          }
        ]
      }
    }
  end
end
