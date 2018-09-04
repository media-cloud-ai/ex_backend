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
          label: "Publish video",
          icon: "share",
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
          label: "Encode audio for Speech-to-Text",
          enable: true,
          parent_ids: [0],
          required: ["upload_file"],
          output_extension: ".wav",
          parameters: [
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
              default: 16000,
              value: 16000
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
          id: 3,
          name: "audio_extraction",
          label: "Encode audio for DASH",
          enable: true,
          parent_ids: [0],
          required: ["upload_file"],
          output_extension: ".mp4",
          parameters: [
            %{
              id: "output_codec_audio",
              type: "string",
              enable: false,
              default: "aac",
              value: "aac"
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
