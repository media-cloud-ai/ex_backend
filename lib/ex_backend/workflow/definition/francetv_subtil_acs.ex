defmodule ExBackend.Workflow.Definition.FrancetvSubtilAcs do
  def get_definition(source_mp4_path, source_ttml_path) do
    %{
      steps: [
        %{
          id: 0,
          name: "download_ftp",
          enable: true,
          parameters: [
            %{
              id: "source_paths",
              type: "paths",
              enable: true,
              default: [source_mp4_path],
              value: [source_mp4_path]
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
              type: "string",
              default: "/343079/http",
              value: "/343079/http"
            }
          ]
        },
        %{
          id: 1,
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
          id: 2,
          parent_ids: [0],
          required: [0],
          name: "download_http",
          enable: true,
          parameters: [
            %{
              id: "source_paths",
              type: "paths",
              enable: true,
              default: [source_ttml_path],
              value: [source_ttml_path]
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
            }
          ]
        },
        %{
          id: 5,
          parent_ids: [4],
          required: [4],
          name: "push_rdf",
          enable: true,
          parameters: [
            %{
              id: "order",
              type: "string",
              default: "publish_ttml",
              value: "publish_ttml"
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
    }
  end
end
