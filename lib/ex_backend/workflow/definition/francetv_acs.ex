defmodule ExBackend.Workflow.Definition.FrancetvAcs do

  def get_definition(audio_url, ttml_url, destination_url) do

    source_steps = [
        %{
          id: 0,
          name: "download_ftp",
          enable: true,
          parameters: [
            %{
              id: "source_paths",
              type: "array_of_strings",
              enable: true,
              default: [audio_url, ttml_url],
              value: [audio_url, ttml_url]
            }
          ]
        }
      ]

    next_step_id = length(source_steps)
    pre_process_steps = get_pre_process_steps(audio_url, next_step_id)
    next_step_id = next_step_id + length(pre_process_steps)

    acs_steps = [
        %{
          id: next_step_id,
          parent_ids: [0, next_step_id - 1],
          required: [0, next_step_id - 1],
          name: "acs_synchronize",
          enable: true,
          parameters: [
            %{
              id: "input_filter",
              type: "filter",
              default: %{ends_with: [".ttml", ".wav"]},
              value: %{ends_with: [".ttml", ".wav"]}
            },
            %{
              id: "threads_number",
              type: "integer",
              enable: true,
              default: 8,
              value: 8
            }
          ]
        }
      ]

    next_step_id = next_step_id + length(acs_steps)

    destination_steps = [
      %{
        id: next_step_id,
        name: "upload_ftp",
        enable: true,
        parent_ids: [next_step_id - 1],
        required: [next_step_id - 1],
        parameters: [
          %{
            id: "input_filter",
            type: "filter",
            default: %{ends_with: "_synchronized.ttml"},
            value: %{ends_with: "_synchronized.ttml"}
          },
          %{
            id: "destination_pattern",
            type: "string",
            value: destination_url <> "#input_filename"
          }
        ]
      }
    ]

    next_step_id = next_step_id + length(destination_steps)

    finish_steps = [
      %{
        id: next_step_id,
        parent_ids: [next_step_id - 1],
        required: [next_step_id - 1],
        name: "clean_workspace",
        enable: true
      }
    ]

    %{
      identifier: "FranceTélévisions ACS (standalone)",
      version_major: 0,
      version_minor: 0,
      version_micro: 0,
      tags: ["francetélévisions", "acs"],
      parameters: [],
      flow: %{
        steps: source_steps
          ++ pre_process_steps
          ++ acs_steps
          ++ destination_steps
          ++ finish_steps
      }
    }
  end

  defp get_pre_process_steps(audio_url, next_step_id) do
    extension =
      String.split(audio_url, ".", trim: true)
      |> List.last

    common_parameters = [
        %{
          id: "output_extension",
          type: "string",
          enable: false,
          default: ".wav",
          value: ".wav"
        },
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
          default: 16_000,
          value: 16_000
        },
        %{
          id: "audio_channels",
          type: "integer",
          enable: false,
          default: 1,
          value: 1
        },
        %{
          id: "audio_filters",
          type: "string",
          enable: false,
          default: "aresample=resampler=soxr:precision=28:dither_method=shibata",
          value: "aresample=precision=28:dither_method=shibata"
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

    case extension do
      "wav" -> []
      "isma" -> [
          %{
            id: next_step_id,
            parent_ids: [0],
            required: [0],
            name: "ism_extraction",
            enable: true,
            parameters: [
              %{
                id: "input_filter",
                type: "filter",
                default: %{ends_with: ".isma"},
                value: %{ends_with: ".isma"}
              },
              %{
                id: "map",
                type: "string",
                value: "0:0"
              }
            ] ++ common_parameters
          }
        ]
      "mp4" -> [
          %{
            id: next_step_id,
            parent_ids: [0],
            required: [0],
            name: "audio_extraction",
            enable: true,
            parameters: [
              %{
                id: "input_filter",
                type: "filter",
                default: %{ends_with: ".mp4"},
                value: %{ends_with: ".mp4"}
              }
            ] ++ common_parameters
          }
        ]
      _ -> []
    end
  end
end
