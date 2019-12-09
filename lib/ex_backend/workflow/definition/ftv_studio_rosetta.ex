defmodule ExBackend.Workflow.Definition.FtvStudioRosetta do
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

    channel =
      case Map.get(video, "channel") do
        nil ->
          "XX"

        value ->
          value
          |> Map.get("id")
          |> format_channel()
      end

    [
      %{
        id: "channel",
        type: "string",
        value: channel
      },
      %{
        id: "broadcasted_at",
        type: "string",
        value: broadcasted_at
      },
      %{
        id: "additional_title",
        type: "string",
        value: additional_title
      },
      %{
        id: "title",
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
        required: [0],
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
        required: [1],
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
              "{source_folder}/{audio}",
              "{source_folder}/{video}"
            ]
          }
        ]
      },
      %{
        id: 3,
        parent_ids: [2],
        required: [2],
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
              "ffmpeg -i {video_filename} -i {audio_filename} -codec:a copy -codec:a copy -map 0:3 -map 1:0 -dn {destination_path}"
          },
          %{
            id: "video_filename",
            type: "template",
            enable: false,
            default: "{Enum.at(source_paths, 0)}",
            value: "{Enum.at(source_paths, 0)}"
          },
          %{
            id: "audio_filename",
            type: "template",
            enable: false,
            default: "{Enum.at(source_paths, 1)}",
            value: "{Enum.at(source_paths, 1)}"
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
        required: [3],
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
        required: [subtitles_step_id],
        parameters: [
          %{
            id: "destination_hostname",
            type: "credential",
            default: "AKAMAI_VIDEO_HOSTNAME",
            value: "AKAMAI_VIDEO_HOSTNAME"
          },
          %{
            id: "destination_username",
            type: "credential",
            default: "AKAMAI_VIDEO_USERNAME",
            value: "AKAMAI_VIDEO_USERNAME"
          },
          %{
            id: "destination_password",
            type: "credential",
            default: "AKAMAI_VIDEO_PASSWORD",
            value: "AKAMAI_VIDEO_PASSWORD"
          },
          %{
            id: "destination_prefix",
            type: "credential",
            default: "AKAMAI_VIDEO_PREFIX",
            value: "AKAMAI_VIDEO_PREFIX"
          },
          %{
            id: "destination_path",
            type: "template",
            default:
              "{channel}/{title}/{channel}_{broadcasted_at}_{title}_{additional_title}{extension}",
            value:
              "{channel}/{title}/{channel}_{broadcasted_at}_{title}_{additional_title}{extension}"
          },
          %{
            id: "ssl",
            type: "credential",
            default: "AKAMAI_VIDEO_SSL",
            value: "AKAMAI_VIDEO_SSL"
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
        parent_ids: [last_step_id + 1],
        name: "job_file_system",
        label: "Clean workspace",
        icon: "delete_forever",
        mode: "one_for_many",
        enable: true,
        parameters: [
          %{
            id: "action",
            type: "string",
            default: "remove",
            value: "remove"
          },
          %{
            id: "source_paths",
            type: "array_of_templates",
            value: [
              "{work_directory}/{workflow_id}"
            ]
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
