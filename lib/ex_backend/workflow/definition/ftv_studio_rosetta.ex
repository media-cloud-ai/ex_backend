defmodule ExBackend.Workflow.Definition.FtvStudioRosetta do
  @moduledoc false

  def get_extra_parameters(video_id) do
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

    [
      %{
        id: "formatted_broadcasted_at",
        type: "string",
        value: broadcasted_at
      },
      %{
        id: "formatted_additional_title",
        type: "string",
        value: additional_title
      },
      %{
        id: "formatted_title",
        type: "string",
        value: title
      }
    ]
  end

  defp format_broadcasted_at(nil) do
    "00000000_0000"
  end

  defp format_broadcasted_at(date) do
    date_object =
      case Timex.parse(date, "%Y-%m-%dT%H:%M:%S", :strftime) do
        {:ok, date_object} ->
          date_object

        {:error, _} ->
          {:ok, parsed} = Timex.parse(date, "{ISO:Extended}")
          parsed
      end

    {:ok, broadcasted_at} = Timex.format(date_object, "%Y%m%d_%H%M", :strftime)
    broadcasted_at
  end

  def get_definition_for_aws_input(source_paths, ttml_path, extra_parameters) do
    steps = [
      %{
        id: 0,
        name: "job_transfer",
        label: "Download ISM Manifest",
        icon: "file_download",
        enable: true,
        parameters: [
          %{
            id: "source_paths",
            type: "array_of_strings",
            enable: true,
            default: source_paths,
            value: source_paths
          },
          %{
            id: "source_access_key",
            type: "credential",
            default: "AWS_FTV_ACCESS_KEY",
            value: "AWS_FTV_ACCESS_KEY"
          },
          %{
            id: "source_secret_key",
            type: "credential",
            default: "AWS_FTV_SECRET_KEY",
            value: "AWS_FTV_SECRET_KEY"
          },
          %{
            id: "source_region",
            type: "credential",
            default: "AWS_FTV_REGION",
            value: "AWS_FTV_REGION"
          },
          %{
            id: "source_prefix",
            type: "credential",
            default: "AWS_FTV_PREFIX",
            value: "AWS_FTV_PREFIX"
          }
        ]
      },
      %{
        id: 1,
        parent_ids: [0],
        required_to_start: [0],
        name: "job_ism_manifest",
        label: "Inspect ISM Manifest",
        icon: "assignment",
        enable: true,
        parameters: []
      },
      %{
        id: 2,
        name: "job_transfer",
        label: "Download source elements",
        icon: "file_download",
        required_to_start: [1],
        enable: true,
        parameters: [
          %{
            id: "source_access_key",
            type: "credential",
            default: "AWS_FTV_ACCESS_KEY",
            value: "AWS_FTV_ACCESS_KEY"
          },
          %{
            id: "source_secret_key",
            type: "credential",
            default: "AWS_FTV_SECRET_KEY",
            value: "AWS_FTV_SECRET_KEY"
          },
          %{
            id: "source_region",
            type: "credential",
            default: "AWS_FTV_REGION",
            value: "AWS_FTV_REGION"
          },
          %{
            id: "source_prefix",
            type: "credential",
            default: "AWS_FTV_PREFIX",
            value: "AWS_FTV_PREFIX"
          },
          %{
            id: "source_paths",
            type: "array_of_templates",
            value: [
              "{source_folder}/<%= Enum.at(Jason.decode!(audio), 0) %>",
              "{source_folder}/<%= Enum.at(Jason.decode!(video), 0) %>"
            ]
          }
        ]
      },
      %{
        id: 3,
        parent_ids: [2],
        required_to_start: [2],
        name: "job_ffmpeg",
        label: "Merge Audio and Video from ISM into MP4",
        icon: "assignment",
        mode: "one_for_many",
        enable: true,
        parameters: [
          %{
            id: "command_template",
            type: "string",
            value:
              "ffmpeg -i {video_filename} -i {audio_filename} -codec:v copy -codec:a copy -map 0:3 -map 1:0 -dn {destination_path}"
          },
          %{
            id: "video_filename",
            type: "template",
            enable: false,
            value:
              "<%= Enum.filter(source_paths, fn item -> String.ends_with?(item, \".ismv\") end) |> List.first %>"
          },
          %{
            id: "audio_filename",
            type: "template",
            enable: false,
            value:
              "<%= Enum.filter(source_paths, fn item -> String.ends_with?(item, \".isma\") end) |> List.first %>"
          },
          %{
            id: "destination_filename",
            type: "template",
            enable: false,
            default: "merged.mp4",
            value: "merged.mp4"
          }
        ]
      },
      %{
        id: 4,
        name: "job_transfer",
        label: "Download TTML Subtitle",
        icon: "file_download",
        enable: true,
        required_to_start: [3],
        parameters: [
          %{
            id: "source_paths",
            type: "array_of_strings",
            enable: true,
            default: [ttml_path],
            value: [ttml_path]
          }
        ]
      }
    ]

    get_definition(steps, 4, 3, 4, extra_parameters)
  end

  def get_definition_for_akamai_input(source_mp4_paths, source_ttml_path, extra_parameters) do
    source_ttml_paths =
      case source_ttml_path do
        nil -> []
        path -> [path]
      end

    steps = [
      %{
        id: 0,
        name: "job_transfer",
        label: "Download sources",
        icon: "file_download",
        enable: true,
        parameters: [
          %{
            id: "source_paths",
            type: "array_of_strings",
            enable: true,
            default: source_mp4_paths ++ source_ttml_paths,
            value: source_mp4_paths ++ source_ttml_paths
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
      }
    ]

    get_definition(steps, 0, 0, 0, extra_parameters)
  end

  def get_definition(steps, last_step_id, video_step_id, subtitles_step_id, extra_parameters) do
    common_steps = [
      %{
        id: last_step_id + 1,
        name: "job_transfer",
        label: "Upload Video with audio and Subtitle",
        icon: "file_upload",
        enable: true,
        parent_ids: [video_step_id, subtitles_step_id],
        required_to_start: [subtitles_step_id],
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
            id: "ssl",
            type: "credential",
            default: "FTP_ROSETTA_SSL",
            value: "FTP_ROSETTA_SSL"
          },
          %{
            id: "destination_path",
            type: "template",
            value:
              "{short_channel}/{formatted_title}/{short_channel}_{formatted_broadcasted_at}_{formatted_title}_{formatted_additional_title}{extension}"
          },
          %{
            "id" => "input_filter",
            "type" => "filter",
            "default" => %{ends_with: [".ttml", ".mp4"]},
            "value" => %{ends_with: [".ttml", ".mp4"]}
          }
        ]
      },
      %{
        id: last_step_id + 2,
        parent_ids: [video_step_id, subtitles_step_id],
        required_to_start: [subtitles_step_id, last_step_id + 1],
        name: "job_file_system",
        label: "Clean workspace",
        icon: "delete_forever",
        mode: "one_for_many",
        enable: true,
        parameters: [
          %{
            id: "action",
            type: "string",
            value: "remove"
          },
          %{
            id: "source_path",
            type: "template",
            value: "{work_directory}/{workflow_id}"
          },
          %{
            id: "source_paths",
            type: "array_of_templates",
            value: [
              "{work_directory}/{workflow_id}"
            ]
          }
        ]
      },
      %{
        id: last_step_id + 3,
        parent_ids: [video_step_id, subtitles_step_id],
        required_to_start: [last_step_id + 2],
        name: "job_notification",
        label: "Notify Rosetta",
        icon: "notifications",
        mode: "notification",
        enable: true,
        parameters: [
          %{
            id: "url",
            type: "template",
            value: "{rosetta_notification_endpoint}"
          },
          %{
            id: "method",
            type: "string",
            value: "POST"
          },
          %{
            id: "headers",
            type: "template",
            value: ~s({
              "content-type": "application/json",
              "X-Requested-With": "XMLHttpRequest",
              "Authorization": "Bearer {rosetta_notification_token}"
            })
          },
          %{
            id: "body",
            type: "template",
            value: ~s({
              "id": "{workflow_reference}",
              "title": "{title}",
              "additional_title": "{additional_title}",
              "broadcasted_at": "{broadcasted_at}",
              "channel": "{channel}",
              "duration": "{duration}",
              "expected_at": "{expected_at}",
              "expected_duration": "{expected_duration}",
              "legacy_id": {legacy_id},
              "oscar_id": "{oscar_id}",
              "aedra_id": "{aedra_id}",
              "plurimedia_broadcast_id": {plurimedia_broadcast_id},
              "plurimedia_collection_ids": {plurimedia_collection_ids},
              "plurimedia_program_id": {plurimedia_program_id},
              "ftvcut_id": "{ftvcut_id}",
              "ttml_path": "<%= Enum.filter(source_paths, fn item -> String.ends_with?(item, ".ttml"\) end\) |> List.first %>",
              "mp4_path": "<%= Enum.filter(source_paths, fn item -> String.ends_with?(item, ".mp4"\) end\) |> List.first %>"
            })
          }
        ]
      }
    ]

    %{
      identifier: "FranceTV Studio Ingest Rosetta",
      version_major: 0,
      version_minor: 0,
      version_micro: 0,
      tags: ["francetv", "studio", "rosetta", "ingest"],
      parameters: extra_parameters,
      steps: steps ++ common_steps
    }
  end
end
