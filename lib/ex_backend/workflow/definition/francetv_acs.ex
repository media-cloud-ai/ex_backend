defmodule ExBackend.Workflow.Definition.FrancetvAcs do

   def get_definition_for_aws_input(source_paths, prefix) do
    steps = [
      %{
        id: 0,
        name: "download_ftp",
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
        name: "ism_manifest",
        enable: true,
        parameters: [
        ]
      },
      %{
        id: 2,
        name: "download_ftp",
        parent_ids: [1],
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
          }
        ]
      },
      %{
        id: 3,
        parent_ids: [2],
        required: [2],
        name: "ism_extraction",
        enable: true,
        parameters: [
          %{
            id: "input_filter",
            type: "filter",
            default: %{ends_with: ".isma"},
            value: %{ends_with: ".isma"}
          },
          %{
            id: "map",
            type: "string",
            value: "0:0"
          },
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
      },
      %{
        id: 4,
        parent_ids: [3],
        required: [3],
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
        id: 5,
        name: "upload_ftp",
        enable: true,
        parent_ids: [4],
        required: [4],
        parameters: [
          %{
            id: "destination_access_key",
            type: "credential",
            default: "AWS_FTV_ACCESS_KEY",
            value: "AWS_FTV_ACCESS_KEY"
          },
          %{
            id: "destination_secret_key",
            type: "credential",
            default: "AWS_FTV_SECRET_KEY",
            value: "AWS_FTV_SECRET_KEY"
          },
          %{
            id: "destination_region",
            type: "credential",
            default: "AWS_FTV_REGION",
            value: "AWS_FTV_REGION"
          },
          %{
            id: "destination_prefix",
            type: "credential",
            default: "AWS_FTV_PREFIX",
            value: "AWS_FTV_PREFIX"
          },
          %{
            id: "input_filter",
            type: "filter",
            default: %{ends_with: "_synchronized.ttml"},
            value: %{ends_with: "_synchronized.ttml"}
          }
        ]
      },
      %{
        id: 6,
        parent_ids: [5],
        required: [5],
        name: "clean_workspace",
        enable: true
      }
    ]

    get_definition(steps, prefix)
  end

  def get_definition_for_akamai_input(source_mp4_paths, source_ttml_path, prefix) do
    source_ttml_paths =
      case source_ttml_path do
        nil -> []
        path -> [path]
      end

    steps = [
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
        name: "download_http",
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
        parent_ids: [0],
        required: [0],
        name: "audio_extraction",
        enable: true,
        parameters: [
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
      },
      %{
        id: 3,
        parent_ids: [1, 2],
        required: [1, 2],
        name: "acs_synchronize",
        enable: true,
        parameters: [
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
        id: 4,
        name: "upload_ftp",
        enable: true,
        parent_ids: [3],
        required: [3],
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
            type: "string",
            default: "/421959/prod/innovation/SubTil/",
            value: "/421959/prod/innovation/SubTil/"
          },
          %{
            id: "input_filter",
            type: "filter",
            default: %{ends_with: "_synchronized.ttml"},
            value: %{ends_with: "_synchronized.ttml"}
          }
        ]
      },
      %{
        id: 5,
        parent_ids: [4],
        required: [4],
        name: "clean_workspace",
        enable: true
      }
    ]

    get_definition(steps, prefix)
  end

  def get_definition(steps, prefix) do
    %{
      identifier: "FranceTélévisions ACS (standalone)",
      version_major: 0,
      version_minor: 0,
      version_micro: 0,
      tags: ["francetélévisions", "acs"],
      parameters: [
        %{
          id: "source_prefix",
          type: "string",
          value: prefix
        }
      ],
      flow: %{
        steps: steps
      }
    }
  end
end
