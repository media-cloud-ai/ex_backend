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
          name: "download_http",
          enable: true,
          parameters: [
            %{
              id: "source_paths",
              type: "paths",
              default: [source_ttml_path],
              value: [source_ttml_path]
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
