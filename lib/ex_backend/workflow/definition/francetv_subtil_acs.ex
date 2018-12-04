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
          parent_ids: [3],
          required: [3],
          name: "push_rdf",
          enable: true
        },
        %{
          id: 5,
          parent_ids: [4],
          required: [4],
          name: "clean_workspace",
          enable: true
        }
      ]
    }
  end
end
