defmodule ExBackend.Workflow.Definition.FtvStudioRosetta do
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
          parent_ids: [2],
          required: [2],
          name: "clean_workspace",
          enable: true
        },
      ]
    }
  end
end
