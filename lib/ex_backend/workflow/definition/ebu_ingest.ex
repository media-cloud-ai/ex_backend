defmodule ExBackend.Workflow.Definition.EbuIngest do
  def get_definition(agent_identifier, input_filename) do
    %{
      steps: [
        %{
          id: 0,
          name: "upload_file",
          enable: true,
          inputs: [
            %{
              path: input_filename,
              agent: agent_identifier
            }
          ]
        },
        %{
          id: 1,
          name: "copy",
          enable: true,
          parent_ids: [0],
          required: ["upload_file"],
          parameters: [
            %{
              id: "output_directory",
              type: "string",
              enable: false,
              default: "/archive",
              value: "/archive"
            }
          ]
        },
        %{
          id: 2,
          name: "audio_extraction",
          enable: true,
          parent_ids: [0],
          required: ["upload_file"],
          output_extension: ".wav",
          parameters: [
            %{
              id: "output_codec_audio",
              type: "string",
              enable: false,
              default: "pcm_s24le",
              value: "pcm_s24le"
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
        }
      ]
    }
  end
end
