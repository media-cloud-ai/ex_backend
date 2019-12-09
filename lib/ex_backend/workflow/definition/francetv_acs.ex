defmodule ExBackend.Workflow.Definition.FrancetvAcs do
  require Logger

  def get_definition(_, _, nil) do
    Logger.info("no TTML for this content, unable to start the workflow")
  end

  def get_definition(nil, mp4_path, ttml_url) do
    [
      %{
        id: 0,
        name: "job_transfer",
        label: "Download source elements",
        icon: "file_download",
        enable: true,
        parameters: [
          %{
            id: "source_paths",
            type: "array_of_strings",
            enable: true,
            default: [mp4_path, ttml_url],
            value: [mp4_path, ttml_url]
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
        name: "job_ffmpeg",
        label: "Extract audio",
        icon: "queue_music",
        enable: true,
        parameters: [
          %{
            id: "input_filter",
            type: "filter",
            default: %{ends_with: [".mp4", ".isma"]},
            value: %{ends_with: [".mp4", ".isma"]}
          },
          %{
            id: "command_template",
            type: "string",
            default:
              "ffmpeg -i {source_path} -codec:a {output_codec_audio} -ar {audio_sampling_rate} -ac {audio_channels} -af {audio_filters} -vn -dn {destination_path}",
            value:
              "ffmpeg -i {source_path} -codec:a {output_codec_audio} -ar {audio_sampling_rate} -ac {audio_channels} -af {audio_filters} -vn -dn {destination_path}"
          },
          %{
            id: "destination_filename",
            type: "template",
            enable: false,
            default: "{source_path}.wav",
            value: "{source_path}.wav"
          },
          %{
            id: "output_codec_audio",
            type: "string",
            enable: false,
            default: "pcm_s16le",
            value: "pcm_s16le"
          },
          %{
            id: "audio_sampling_rate",
            type: "integer",
            enable: false,
            default: 16_000,
            value: 16_000
          },
          %{
            id: "audio_channels",
            type: "integer",
            enable: false,
            default: 1,
            value: 1
          },
          %{
            id: "audio_filters",
            type: "string",
            enable: false,
            default: "aresample=resampler=soxr:precision=28:dither_method=shibata",
            value: "aresample=precision=28:dither_method=shibata"
          }
        ]
      },
      %{
        id: 2,
        parent_ids: [0, 1],
        required: [0, 1],
        name: "job_acs",
        label: "Audio Content Synchronisation",
        icon: "music_video",
        enable: true,
        mode: "one_for_many",
        parameters: [
          %{
            id: "input_filter",
            type: "filter",
            default: %{ends_with: [".ttml", ".wav"]},
            value: %{ends_with: [".ttml", ".wav"]}
          },
          %{
            id: "command_template",
            type: "string",
            default:
              "acs_launcher.sh {audio_path} {subtitle_path} {destination_path} {threads_number}",
            value:
              "acs_launcher.sh {audio_path} {subtitle_path} {destination_path} {threads_number}"
          },
          %{
            id: "subtitle_path",
            type: "select_input",
            default: %{ends_with: [".ttml"]},
            value: %{ends_with: [".ttml"]}
          },
          %{
            id: "audio_path",
            type: "select_input",
            default: %{ends_with: [".wav"]},
            value: %{ends_with: [".wav"]}
          },
          %{
            id: "destination_filename",
            type: "template",
            enable: false,
            default: "synchronised.ttml",
            value: "synchronised.ttml"
          },
          %{
            id: "threads_number",
            type: "integer",
            enable: true,
            default: 8,
            value: 8
          }
        ]
      },
      %{
        id: 3,
        name: "job_transfer",
        label: "Upload generated elements to S3",
        icon: "file_upload",
        enable: true,
        parent_ids: [0, 2],
        required: [0, 2],
        parameters: [
          %{
            id: "destination_hostname",
            type: "credential",
            default: "S3_STORAGE_HOSTNAME",
            value: "S3_STORAGE_HOSTNAME"
          },
          %{
            id: "destination_access_key",
            type: "credential",
            default: "S3_STORAGE_ACCESS_KEY",
            value: "S3_STORAGE_ACCESS_KEY"
          },
          %{
            id: "destination_secret_key",
            type: "credential",
            default: "S3_STORAGE_SECRET_KEY",
            value: "S3_STORAGE_SECRET_KEY"
          },
          %{
            id: "destination_prefix",
            type: "credential",
            default: "S3_STORAGE_BUCKET",
            value: "S3_STORAGE_BUCKET"
          },
          %{
            id: "destination_region",
            type: "credential",
            default: "S3_STORAGE_REGION",
            value: "S3_STORAGE_REGION"
          },
          %{
            id: "destination_path",
            type: "template",
            default: "{workflow_reference}/{date_time}/{filename}",
            value: "{workflow_reference}/{date_time}/{filename}"
          }
        ]
      },
      %{
        id: 4,
        parent_ids: [3],
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
    |> create_workflow()
  end

  defp create_workflow(steps) do
    %{
      identifier: "FranceTélévisions ACS (standalone)",
      version_major: 0,
      version_minor: 0,
      version_micro: 1,
      tags: ["francetélévisions", "acs"],
      parameters: [],
      steps: steps
    }
  end
end
