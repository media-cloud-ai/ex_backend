defmodule ExBackend.Workflow.Definition.FrancetvSubtilIngest do
  def get_definition(acs_enable) do
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
          parent_ids: [2],
          required: [2],
          name: "audio_decode",
          enable: acs_enable
        },
        %{
          id: 4,
          parent_ids: [3],
          required: [3],
          name: "acs_prepare_audio",
          enable: acs_enable
        },
        %{
          id: 5,
          parent_ids: [4],
          required: [4],
          name: "acs_synchronize",
          enable: acs_enable,
          parameters: [
            %{
              id: "threads_number",
              type: "number",
              default: 8,
              value: 8
            },
            %{
              id: "keep_original",
              type: "boolean",
              default: false,
              value: false
            }
          ]
        },
        %{
          id: 6,
          parent_ids: [1, 5],
          required: [1],
          name: "ttml_to_mp4",
          enable: true
        },
        %{
          id: 7,
          parent_ids: [6],
          required: [2, 6],
          name: "set_language",
          enable: true
        },
        %{
          id: 8,
          parent_ids: [7, 0],
          required: [7, 0],
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
          id: 9,
          parent_ids: [8],
          required: [8],
          name: "upload_ftp",
          enable: true
        },
        %{
          id: 10,
          parent_ids: [9],
          required: [9],
          name: "push_rdf",
          enable: true
        },
        %{
          id: 11,
          parent_ids: [10],
          required: [0],
          name: "clean_workspace",
          enable: true
        }
      ]
    }
  end
end
