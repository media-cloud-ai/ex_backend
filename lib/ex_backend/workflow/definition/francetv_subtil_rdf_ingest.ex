defmodule ExBackend.Workflow.Definition.FrancetvSubtilRdfIngest do

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
        required: [0],
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
            "id" => "output_codec_video",
            "type" => "string",
            "value" => "copy"
          },
          %{
            "id" => "output_codec_audio",
            "type" => "string",
            "value" => "copy"
          },
          %{
            "id" => "map",
            "type" => "string",
            "value" => "0:4"
          },
          %{
            "id" => "map",
            "type" => "string",
            "value" => "1:0"
          }
        ]
      }
    ]

    get_definition(steps, 3, 2, 3, prefix)
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
      }
    ]

    get_definition(steps, 1, 0, 1, prefix)
  end

  def get_definition(steps, last_step_id, video_step_id, subtitles_step_id, prefix) do
    common_steps = [
      %{
        id: last_step_id + 1,
        name: "upload_ftp",
        enable: true,
        parent_ids: [video_step_id, subtitles_step_id],
        required: [subtitles_step_id],
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
            type: "string",
            default: "/mnt/data/",
            value: "/mnt/data/"
          },
          %{
            id: "ssl",
            type: "boolean",
            default: false,
            value: false
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
        required: [last_step_id + 1],
        name: "clean_workspace",
        enable: true
      },
      %{
        id: last_step_id + 3,
        name: "push_rdf",
        enable: true,
        parent_ids: [last_step_id + 1],
        required: [last_step_id + 2],
        parameters: [
          %{
            id: "perfect_memory_username",
            type: "credential",
            default: "PERFECT_MEMORY_USERNAME",
            value: "PERFECT_MEMORY_USERNAME"
          },
          %{
            id: "perfect_memory_password",
            type: "credential",
            default: "PERFECT_MEMORY_PASSWORD",
            value: "PERFECT_MEMORY_PASSWORD"
          },
          %{
            id: "perfect_memory_endpoint",
            type: "credential",
            default: "PERFECT_MEMORY_ENDPOINT",
            value: "PERFECT_MEMORY_ENDPOINT"
          },
          %{
            id: "perfect_memory_event_name",
            type: "string",
            value: "push_rdf_infos"
          }
        ]
      }
    ]

    %{
      identifier: "FranceTélévisions Rdf Ingest",
      version_major: 0,
      version_minor: 0,
      version_micro: 0,
      tags: ["francetélévisions", "rdf", "ingest"],
      parameters: [
        %{
          id: "source_prefix",
          type: "string",
          value: prefix
        }
      ],
      flow: %{
        steps: steps ++ common_steps
      }
    }
  end
end
