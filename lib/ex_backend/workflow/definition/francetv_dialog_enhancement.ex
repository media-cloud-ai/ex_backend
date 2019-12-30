defmodule ExBackend.Workflow.Definition.FrancetvDialogEnhancement do
  @moduledoc false

  require Logger

  def get_definition() do
    %{
      identifier: "FranceTélévisions Audio",
      version_major: 0,
      version_minor: 0,
      version_micro: 1,
      tags: ["francetélévisions", "dialog_enhancement"],
      parameters: [],
      steps: [
        %{
          id: 0,
          name: "job_transfer",
          label: "Download source elements",
          icon: "file_download",
          enable: true,
          parameters: [
            %{
              id: "source_paths",
              type: "template",
              value: "{source_filename}"
            },
            %{
              id: "source_hostname",
              type: "credential",
              value: "S3_STORAGE_HOSTNAME"
            },
            %{
              id: "source_access_key",
              type: "credential",
              value: "S3_STORAGE_ACCESS_KEY"
            },
            %{
              id: "source_secret_key",
              type: "credential",
              value: "S3_STORAGE_SECRET_KEY"
            },
            %{
              id: "source_prefix",
              type: "credential",
              value: "S3_STORAGE_BUCKET"
            },
            %{
              id: "source_region",
              type: "credential",
              value: "S3_STORAGE_REGION"
            }
          ]
        },
        %{
          id: 1,
          parent_ids: [0],
          required: [0],
          name: "job_ffmpeg",
          label: "Convert audio",
          icon: "queue_music",
          enable: true,
          parameters: [
            %{
              id: "command_template",
              type: "string",
              default:
                "ffmpeg -i {source_path} -codec:a {output_codec_audio} -ar {audio_sampling_rate} -vn -dn {destination_path}",
              value:
                "ffmpeg -i {source_path} -codec:a {output_codec_audio} -ar {audio_sampling_rate} -vn -dn {destination_path}"
            },
            %{
              id: "destination_path",
              type: "template",
              value: "{work_directory}/{workflow_id}/audio_track.wav"
            },
            %{
              id: "output_codec_audio",
              type: "string",
              value: "pcm_s24le"
            },
            %{
              id: "audio_sampling_rate",
              type: "integer",
              value: 48_000
            }
          ]
        },
        %{
          id: 2,
          parent_ids: [1],
          required: [1],
          name: "job_extractor",
          label: "Dialog Extraction",
          icon: "call_split",
          enable: true,
          parameters: [
            %{
              id: "command_template",
              type: "string",
              value: "extractor {source_path} {destination_path}"
            },
            %{
              id: "destination_path",
              type: "template",
              value: "{work_directory}/{workflow_id}/audio_split_tracks.wav"
            }
          ]
        },
        %{
          id: 3,
          parent_ids: [2],
          required: [2],
          name: "job_adm_loudness",
          label: "Dialog Enhancement",
          icon: "record_voice_over",
          enable: true,
          skip_destination_path: true,
          parameters: [
            %{
              id: "input",
              type: "template",
              value: "{source_path}"
            },
            %{
              id: "output",
              type: "template",
              value: "{work_directory}/{workflow_id}"
            },
            %{
              id: "display",
              type: "boolean",
              value: true
            },
            %{
              id: "correction",
              type: "boolean",
              value: true
            },
            %{
              id: "limiter",
              type: "boolean",
              value: true
            },
            %{
              id: "element_id",
              type: "string",
              value: "APR_1002"
            },
            %{
              id: "gain_mapping",
              type: "array_of_templates",
              value: [
                "ACO_1003={dialog_gain}",
                "ACO_1004={ambiance_gain}"
              ]
            }
          ]
        },
        %{
          id: 4,
          name: "job_transfer",
          label: "Upload generated elements to S3",
          icon: "file_upload",
          enable: true,
          parent_ids: [3],
          required: [3],
          parameters: [
            %{
              id: "destination_hostname",
              type: "credential",
              default: "S3_STORAGE_HOSTNAME",
              value: "S3_STORAGE_HOSTNAME"
            },
            %{
              id: "destination_access_key",
              type: "credential",
              default: "S3_STORAGE_ACCESS_KEY",
              value: "S3_STORAGE_ACCESS_KEY"
            },
            %{
              id: "destination_secret_key",
              type: "credential",
              default: "S3_STORAGE_SECRET_KEY",
              value: "S3_STORAGE_SECRET_KEY"
            },
            %{
              id: "destination_prefix",
              type: "credential",
              default: "S3_STORAGE_BUCKET",
              value: "S3_STORAGE_BUCKET"
            },
            %{
              id: "destination_region",
              type: "credential",
              default: "S3_STORAGE_REGION",
              value: "S3_STORAGE_REGION"
            },
            %{
              id: "destination_path",
              type: "template",
              value: "{workflow_id}/dialog_enhanced.wav"
            }
          ]
        },
        %{
          id: 3,
          parent_ids: [2],
          name: "job_file_system",
          label: "Clean workspace",
          icon: "delete_forever",
          mode: "one_for_many",
          enable: true,
          parameters: [
            %{
              id: "action",
              type: "string",
              default: "remove",
              value: "remove"
            },
            %{
              id: "source_paths",
              type: "array_of_templates",
              value: [
                "{work_directory}/{workflow_id}"
              ]
            }
          ]
        }
      ]
    }
  end
end
