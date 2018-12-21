defmodule ExBackend.Workflow.Definition.FrancetvSubtilDashIngest do
  def get_definition(source_mp4_paths, source_ttml_path) do
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
          label: "Extract audio track",
          name: "audio_extraction",
          enable: true,
          parameters: [
            %{
              "id" => "input_filter",
              "type" => "filter",
              "default" => %{ends_with: "standard1.mp4"},
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
          id: 2,
          parent_ids: [1],
          required: [1],
          label: "Set language of the audio track",
          name: "set_language",
          enable: true
        },
        %{
          id: 3,
          parent_ids: [2, 0],
          required: [2, 0],
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
            },
            %{
              id: "profile",
              type: "string",
              default: "onDemand",
              value: "onDemand"
            },
            %{
              id: "rap",
              type: "boolean",
              default: true,
              value: true
            },
            %{
              id: "url_template",
              type: "boolean",
              default: true,
              value: true
            }
          ]
        },
        %{
          id: 4,
          parent_ids: [3],
          required: [3],
          label: "Download TTML subtitle with HTTP",
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
          id: 5,
          parent_ids: [4],
          required: [4],
          label: "Copy TTML subtitle",
          icon: "file_copy",
          name: "copy",
          enable: true,
          parameters: [
            %{
              id: "output_directory",
              type: "string",
              enable: true,
              default: "#work_dir/#workflow_id/dash",
              value: "#work_dir/#workflow_id/dash"
            }
          ]
        },
        %{
          id: 6,
          parent_ids: [3, 5],
          required: [3, 5],
          label: "Insert subtitle track",
          icon: "subtitles",
          name: "dash_manifest",
          enable: true,
          parameters: [
            %{
              id: "ttml_language",
              type: "string",
              enable: true,
              default: "fra",
              value: "fra"
            },%{
              id: "ttml_role",
              type: "string",
              enable: true,
              default: "subtitle",
              value: "subtitle"
            }
          ]
        },
        %{
          id: 7,
          parent_ids: [3, 5],
          required: [3, 5],
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
              type: "string",
              default: "/421959/prod/innovation/SubTil/",
              value: "/421959/prod/innovation/SubTil/"
            }
          ]
        },
        # %{
        #   id: 6,
        #   parent_ids: [5],
        #   required: [5],
        #   label: "Add DASH reference to the related Editorial Object",
        #   name: "push_rdf",
        #   enable: true
        # },
        %{
          # id: 7,
          # parent_ids: [6],
          # required: [6],
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
