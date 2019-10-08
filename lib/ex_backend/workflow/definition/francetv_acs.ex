defmodule ExBackend.Workflow.Definition.FrancetvAcs do

  require Logger

  def get_definition(_, _, nil, _) do
    Logger.info("no TTML for this content, unable to start the workflow")
  end

  def get_definition(nil, mp4_path, ttml_url, destination_url) do
    [
      %{
        id: 0,
        name: "download_ftp",
        enable: true,
        parameters: [
          %{
            id: "source_paths",
            type: "array_of_strings",
            enable: true,
            default: [mp4_path, ttml_url],
            value: [mp4_path, ttml_url]
          }
        ] ++ get_akamai_source_parameters()
      },
      %{
        id: 1,
        parent_ids: [0],
        required: [0],
        name: "audio_extraction",
        enable: true,
        parameters: [
          %{
            id: "input_filter",
            type: "filter",
            default: %{ends_with: [".mp4", ".isma"]},
            value: %{ends_with: [".mp4", ".isma"]}
          }
        ] ++ get_audio_encoding_parameters()
      },
      %{
        id: 2,
        parent_ids: [0, 1],
        required: [0, 1],
        name: "acs_synchronize",
        enable: true,
        parameters: [
          %{
            id: "input_filter",
            type: "filter",
            default: %{ends_with: [".ttml", ".wav"]},
            value: %{ends_with: [".ttml", ".wav"]}
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
        name: "upload_ftp",
        enable: true,
        parent_ids: [0, 2],
        required: [0, 2],
        parameters: get_s3_upload_parameters()
      },
      %{
        id: 4,
        parent_ids: [3],
        required: [3],
        name: "clean_workspace",
        enable: true
      }
    ]
    |> create_workflow()
  end

  defp get_akamai_source_parameters() do
    [
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
  end

  defp get_audio_encoding_parameters() do
    [
      %{
        id: "output_extension",
        type: "string",
        enable: false,
        default: ".wav",
        value: ".wav"
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
      },
      %{
        id: "disable_video",
        type: "boolean",
        enable: false,
        default: true,
        value: true
      },
      %{
        id: "disable_data",
        type: "boolean",
        enable: false,
        default: true,
        value: true
      }
    ]
  end

  defp get_s3_upload_parameters() do
    [
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
    ]
  end

  defp create_workflow(steps) do
    %{
      identifier: "FranceTélévisions ACS (standalone)",
      version_major: 0,
      version_minor: 0,
      version_micro: 1,
      tags: ["francetélévisions", "acs"],
      parameters: [],
      flow: %{
        steps: steps
      }
    }
  end
end
