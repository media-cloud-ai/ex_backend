defmodule ExBackend.Workflow.Definition.FrancetvSubtilRdfIngest do
  def get_definition(source_mp4_paths, source_ttml_path) do
    source_ttml_paths =
      case source_ttml_path do
        nil -> []
        path -> [path]
      end

    %{
      identifier: "FranceTélévisions Rdf Ingest",
      version_major: 0,
      version_minor: 0,
      version_micro: 0,
      tags: ["francetélévisions", "rdf", "ingest"],
      flow: %{
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
            enable: true,
            parameters: [
              %{
                id: "source_paths",
                type: "paths",
                enable: true,
                default: source_ttml_paths,
                value: source_ttml_paths
              }
            ]
          },
          %{
            id: 2,
            name: "upload_ftp",
            enable: true,
            parent_ids: [0, 1],
            required: [0, 1],
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
                default: "/home/Rosetta/",
                value: "/home/Rosetta/"
              },
              %{
                id: "ssl",
                type: "boolean",
                default: true,
                value: true
              }
            ]
          },
          %{
            id: 3,
            name: "push_rdf",
            enable: true,
            parent_ids: [2],
            required: [2],
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
          },
          %{
            id: 4,
            parent_ids: [3],
            required: [3],
            name: "clean_workspace",
            enable: true
          }
        ]
      }
    }
  end
end
