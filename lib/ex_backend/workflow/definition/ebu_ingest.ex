defmodule ExBackend.Workflow.Definition.EbuIngest do
  def get_definition(agent_identifier, input_filename) do
    root_dash_content =
      System.get_env("ROOT_DASH_CONTENT") || Application.get_env(:ex_backend, :root_dash_content)
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
          required: [0],
          parameters: [
            %{
              id: "output_directory",
              type: "string",
              enable: false,
              default: "/archive/#workflow_id",
              value: "/archive/#workflow_id"
            }
          ]
        },
        %{
          id: 2,
          name: "audio_extraction",
          label: "Encode audio for Speech-to-Text",
          enable: true,
          parent_ids: [0],
          required: [0],
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
              id: "audio_channels",
              type: "integer",
              enable: false,
              default: 1,
              value: 1
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
          icon: "volume_up",
          enable: true,
          parent_ids: [0],
          required: [0],
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
        },
        %{
          id: 4,
          name: "audio_extraction",
          label: "Encode video for DASH",
          icon: "local_movies",
          enable: true,
          parent_ids: [0],
          required: [0],
          output_extension: "-standard5.mp4",
          parameters: [
            %{
              id: "output_codec_video",
              type: "string",
              enable: false,
              default: "libx264",
              value: "libx264"
            },
            %{
              id: "profile_video",
              type: "string",
              enable: false,
              default: "baseline",
              value: "baseline"
            },
            %{
              id: "pixel_format",
              type: "string",
              enable: false,
              default: "yuv420p",
              value: "yuv420p"
            },
            %{
              id: "colorspace",
              type: "string",
              enable: false,
              default: "bt709",
              value: "bt709"
            },
            %{
              id: "color_trc",
              type: "string",
              enable: false,
              default: "bt709",
              value: "bt709"
            },
            %{
              id: "color_primaries",
              type: "string",
              enable: false,
              default: "bt709",
              value: "bt709"
            },
            %{
              id: "max_bitrate",
              type: "string",
              enable: false,
              default: "5M",
              value: "5M"
            },
            %{
              id: "buffer_size",
              type: "string",
              enable: false,
              default: "5M",
              value: "5M"
            },
            %{
              id: "rc_init_occupancy",
              type: "string",
              enable: false,
              default: "5M",
              value: "5M"
            },
            %{
              id: "preset",
              type: "string",
              enable: false,
              default: "slow",
              value: "slow"
            },
            %{
              id: "x264-params",
              type: "string",
              enable: false,
              default: "keyint=50:min-keyint=50:no-scenecut",
              value: "keyint=50:min-keyint=50:no-scenecut"
            },
            %{
              id: "deblock",
              type: "string",
              enable: false,
              default: "2:2",
              value: "2:2"
            },
            %{
              id: "write_timecode",
              type: "boolean",
              enable: false,
              default: false,
              value: false
            },
            %{
              id: "disable_audio",
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
          id: 5,
          name: "speech_to_text",
          enable: true,
          parent_ids: [2],
          required: [2],
          parameters: [
            %{
              id: "language",
              type: "string",
              enable: false,
              default: "en-US",
              value: "en-US"
            },
            %{
              id: "format",
              type: "string",
              enable: false,
              default: "simple",
              value: "simple"
            },
            %{
              id: "mode",
              type: "string",
              enable: false,
              default: "conversation",
              value: "conversation"
            }
          ]
        },
        %{
          id: 6,
          name: "copy",
          label: "Archive Subtitle",
          icon: "archive",
          enable: true,
          required: [5],
          parent_ids: [5],
          parameters: [
            %{
              id: "output_directory",
              type: "string",
              enable: false,
              default: root_dash_content <> "/#workflow_id",
              value: root_dash_content <> "/#workflow_id"
            }
          ]
        },
        %{
          id: 7,
          name: "register",
          label: "Register Subtitle",
          icon: "subscriptions",
          enable: true,
          required: [6],
          parent_ids: [6],
          parameters: [
            %{
              id: "extensions",
              type: "string",
              enable: false,
              default: ".vtt",
              value: ".vtt",
            },
            %{
              id: "name",
              type: "string",
              enable: false,
              default: "master",
              value: "master",
            },
            %{
              id: "type",
              type: "string",
              enable: false,
              default: "subtitle",
              value: "subtitle",
            },
            %{
              id: "language",
              type: "string",
              enable: false,
              default: "eng",
              value: "eng",
            }
          ]
        },
        %{
          id: 8,
          name: "set_language",
          label: "Set language",
          enable: true,
          required: [3],
          parent_ids: [3],
          parameters: [
            %{
              id: "language",
              type: "string",
              enable: false,
              default: "eng",
              value: "eng"
            }
          ]
        },
        %{
          id: 9,
          name: "generate_dash",
          label: "Package DASH",
          enable: true,
          required: [8, 4],
          parent_ids: [8, 4],
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
          id: 10,
          name: "copy",
          label: "Archive DASH",
          icon: "archive",
          enable: true,
          required: [9],
          parent_ids: [9],
          parameters: [
            %{
              id: "output_directory",
              type: "string",
              enable: false,
              default: root_dash_content <> "/#workflow_id",
              value: root_dash_content <> "/#workflow_id"
            }
          ]
        },
        %{
          id: 11,
          name: "register",
          label: "Register DASH",
          icon: "subscriptions",
          enable: true,
          required: [10],
          parent_ids: [10],
          parameters: [
            %{
              id: "extensions",
              type: "string",
              enable: false,
              default: ".mpd",
              value: ".mpd",
            },
            %{
              id: "name",
              type: "string",
              enable: false,
              default: "master",
              value: "master",
            },
            %{
              id: "type",
              type: "string",
              enable: false,
              default: "manifest_dash",
              value: "manifest_dash",
            }
          ]
        },
      ]
    }
  end
end
