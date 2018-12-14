defmodule ExBackend.Workflow.Definition.FrancetvSubtilDashIngest do
  def get_definition(source_mp4_paths) do
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
          name: "download_http",
          enable: true
        },
        %{
          id: 2,
          parent_ids: [0],
          required: [0],
          name: "audio_extraction",
          enable: true,
          parameters: [
            %{
              "id" => "input_filter",
              "type" => "filter",
              "default" => "standard1.mp4",
              "value" => %{ends_with: "standard1.mp4"},
            },
            %{
              "id" => "output_codec_audio",
              "type" => "string",
              "default" => "copy",
              "value" => "copy"
            },
            %{
              "id" => "force_overwrite",
              "type" => "boolean",
              "default" => true,
              "value" => true
            },
            %{
              "id" => "disable_video",
              "type" => "boolean",
              "default" => true,
              "value" => true
            },
            %{
              "id" => "disable_data",
              "type" => "boolean",
              "default" => true,
              "value" => true
            }
          ]
        },
        %{
          id: 3,
          parent_ids: [1, 2],
          required: [1],
          name: "ttml_to_mp4",
          enable: true
        },
        %{
          id: 4,
          parent_ids: [3],
          required: [2, 3],
          name: "set_language",
          enable: true
        },
        %{
          id: 5,
          parent_ids: [4, 0],
          required: [4, 0],
          name: "generate_dash",
          enable: true,
          parameters: [
            %{
              id: "segment_duration",
              type: "integer",
              default: 2000,
              value: 2000
            },
            %{
              id: "fragment_duration",
              type: "integer",
              default: 2000,
              value: 2000
            }
          ]
        },
        %{
          id: 6,
          parent_ids: [5],
          required: [5],
          name: "upload_ftp",
          enable: true,
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
            }
          ]
        },
        %{
          id: 7,
          parent_ids: [6],
          required: [6],
          name: "push_rdf",
          enable: true
        },
        %{
          id: 8,
          parent_ids: [7],
          required: [0],
          name: "clean_workspace",
          enable: true
        }
      ]
    }
  end
end
