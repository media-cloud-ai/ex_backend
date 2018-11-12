defmodule ExBackend.Workflow.Definition.FrancetvSubtilDashIngest do
  def get_definition() do
    %{
      steps: [
        %{
          id: 0,
          name: "download_ftp",
          enable: true
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
          enable: true
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
              type: "number",
              default: 2000,
              value: 2000
            },
            %{
              id: "fragment_duration",
              type: "number",
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
          enable: true
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
