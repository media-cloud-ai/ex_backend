defmodule ExSubtilBackend.Workflow.Step.GenerateDashTest do
  use ExUnit.Case
  alias ExSubtilBackend.Workflow.Step.GenerateDash
  doctest GenerateDash

  test "skipped step" do
    alias ExSubtilBackend.Workflows.Workflow
    alias ExSubtilBackend.Jobs.Job

    workflow = %Workflow{
      id: 666,
      reference: "reference_id",
      flow: %{steps: []},
      jobs: []
    }

    step = %{
      "parameters" => [
      ]
    }

    result = GenerateDash.build_step_parameters(workflow, step)
    assert result == {:skipped, nil}
  end

  test "video only" do
    alias ExSubtilBackend.Workflows.Workflow
    alias ExSubtilBackend.Jobs.Job

    workflow = %Workflow{
      id: 666,
      reference: "reference_id",
      flow: %{steps: []},
      jobs: [
        %Job{
          name: "download_ftp",
          params: %{
            "destination" => %{
              "path" => "/2018/S12/J7/173535163-5ab81c23a3594-standard3.mp4"
            }
          }
        }
      ]
    }

    step = %{
      "parameters" => [
        %{
          "id" => "segment_duration",
          "value" => 20000
        },
        %{
          "id" => "fragment_duration",
          "value" => 60000
        }
      ]
    }

    result = GenerateDash.build_step_parameters(workflow, step)
    assert result == {
      :ok,
      %{
        name: "generate_dash",
        params: %{
          kind: "generate_dash",
          options: %{
            "-out": "/tmp/ftp_francetv/dash/reference_id/manifest.mpd",
            "-profile": "onDemand",
            "-rap": true,
            "-url-template": true,
            "-dash": 20000,
            "-frag": 60000
          },
          requirements: %{
            paths: [
              "/2018/S12/J7/173535163-5ab81c23a3594-standard3.mp4"
            ]
          },
          source: %{
            paths: [
              "/2018/S12/J7/173535163-5ab81c23a3594-standard3.mp4#video:id=v3"
            ]
          }
        },
        workflow_id: 666
      }
    }
  end

  test "video with 1 audio" do
    alias ExSubtilBackend.Workflows.Workflow
    alias ExSubtilBackend.Jobs.Job

    workflow = %Workflow{
      id: 666,
      reference: "reference_id",
      flow: %{steps: []},
      jobs: [
        %Job{
          name: "download_ftp",
          params: %{
            "destination" => %{
              "path" => "/2018/S12/J7/173535163-5ab81c23a3594-standard1.mp4"
            }
          }
        },
        %Job{
          name: "audio_extraction",
          params: %{
            "destination" => %{
              "paths" => ["/2018/S12/J7/173535163-5ab81c23a3594-fra.mp4"]
            }
          }
        }
      ]
    }

    step = %{
      "parameters" => [
        %{
          "id" => "segment_duration",
          "value" => 20000
        },
        %{
          "id" => "fragment_duration",
          "value" => 60000
        }
      ]
    }

    result = GenerateDash.build_step_parameters(workflow, step)
    assert result == {
      :ok,
      %{
        name: "generate_dash",
        params: %{
          kind: "generate_dash",
          options: %{
            "-out": "/tmp/ftp_francetv/dash/reference_id/manifest.mpd",
            "-profile": "onDemand",
            "-rap": true,
            "-url-template": true,
            "-dash": 20000,
            "-frag": 60000
          },
          requirements: %{
            paths: [
              "/2018/S12/J7/173535163-5ab81c23a3594-fra.mp4",
              "/2018/S12/J7/173535163-5ab81c23a3594-standard1.mp4"
            ]
          },
          source: %{
            paths: [
              "/2018/S12/J7/173535163-5ab81c23a3594-fra.mp4#audio:id=a1",
              "/2018/S12/J7/173535163-5ab81c23a3594-standard1.mp4#video:id=v5"
            ]
          }
        },
        workflow_id: 666
      }
    }
  end

  test "video with 1 audio and 1 Audio Description" do
    alias ExSubtilBackend.Workflows.Workflow
    alias ExSubtilBackend.Jobs.Job

    workflow = %Workflow{
      id: 666,
      reference: "reference_id",
      flow: %{steps: []},
      jobs: [
        %Job{
          name: "download_ftp",
          params: %{
            "destination" => %{
              "path" => "/2018/S12/J7/173535163-5ab81c23a3594-standard1.mp4"
            }
          }
        },
        %Job{
          name: "download_ftp",
          params: %{
            "destination" => %{
              "path" => "/2018/S12/J7/173535163-5ab81c23a3594-qad.mp4"
            }
          }
        },
        %Job{
          name: "audio_extraction",
          params: %{
            "destination" => %{
              "paths" => ["/2018/S12/J7/173535163-5ab81c23a3594-fra.mp4"]
            }
          }
        }
      ]
    }

    step = %{
      "parameters" => [
        %{
          "id" => "segment_duration",
          "value" => 20000
        },
        %{
          "id" => "fragment_duration",
          "value" => 60000
        }
      ]
    }

    result = GenerateDash.build_step_parameters(workflow, step)
    assert result == {
      :ok,
        %{
        name: "generate_dash",
        params: %{
          kind: "generate_dash",
          options: %{
            "-out": "/tmp/ftp_francetv/dash/reference_id/manifest.mpd",
            "-profile": "onDemand",
            "-rap": true,
            "-url-template": true,
            "-dash": 20000,
            "-frag": 60000
          },
          requirements: %{
            paths: [
              "/2018/S12/J7/173535163-5ab81c23a3594-fra.mp4",
              "/2018/S12/J7/173535163-5ab81c23a3594-qad.mp4",
              "/2018/S12/J7/173535163-5ab81c23a3594-standard1.mp4"
            ]
          },
          source: %{
            paths: [
              "/2018/S12/J7/173535163-5ab81c23a3594-fra.mp4#audio:id=a1",
              "/2018/S12/J7/173535163-5ab81c23a3594-qad.mp4#audio:id=a2",
              "/2018/S12/J7/173535163-5ab81c23a3594-standard1.mp4#video:id=v5"
            ]
          }
        },
        workflow_id: 666
      }
    }
  end

  test "video with 1 audio and 1 original version" do
    alias ExSubtilBackend.Workflows.Workflow
    alias ExSubtilBackend.Jobs.Job

    workflow = %Workflow{
      id: 666,
      reference: "reference_id",
      flow: %{steps: []},
      jobs: [
        %Job{
          name: "download_ftp",
          params: %{
            "destination" => %{
              "path" => "/2018/S12/J7/173535163-5ab81c23a3594-standard1.mp4"
            }
          }
        },
        %Job{
          name: "download_ftp",
          params: %{
            "destination" => %{
              "path" => "/2018/S12/J7/173535163-5ab81c23a3594-qaa.mp4"
            }
          }
        },
        %Job{
          name: "audio_extraction",
          params: %{
            "destination" => %{
              "paths" => ["/2018/S12/J7/173535163-5ab81c23a3594-fra.mp4"]
            }
          }
        }
      ]
    }

    step = %{
      "parameters" => [
        %{
          "id" => "segment_duration",
          "value" => 20000
        },
        %{
          "id" => "fragment_duration",
          "value" => 60000
        }
      ]
    }

    result = GenerateDash.build_step_parameters(workflow, step)
    assert result == {
      :ok,
      %{
        name: "generate_dash",
        params: %{
          kind: "generate_dash",
          options: %{
            "-out": "/tmp/ftp_francetv/dash/reference_id/manifest.mpd",
            "-profile": "onDemand",
            "-rap": true,
            "-url-template": true,
            "-dash": 20000,
            "-frag": 60000
          },
          requirements: %{
            paths: [
              "/2018/S12/J7/173535163-5ab81c23a3594-fra.mp4",
              "/2018/S12/J7/173535163-5ab81c23a3594-qaa.mp4",
              "/2018/S12/J7/173535163-5ab81c23a3594-standard1.mp4"
            ]
          },
          source: %{
            paths: [
              "/2018/S12/J7/173535163-5ab81c23a3594-fra.mp4#audio:id=a1",
              "/2018/S12/J7/173535163-5ab81c23a3594-qaa.mp4#audio:id=a2",
              "/2018/S12/J7/173535163-5ab81c23a3594-standard1.mp4#video:id=v5"
            ]
          }
        },
        workflow_id: 666
      }
    }
  end
  test "video with 1 audio and 1 original version and 1 audio description" do
    alias ExSubtilBackend.Workflows.Workflow
    alias ExSubtilBackend.Jobs.Job

    workflow = %Workflow{
      id: 666,
      reference: "reference_id",
      flow: %{steps: []},
      jobs: [
        %Job{
          name: "download_ftp",
          params: %{
            "destination" => %{
              "path" => "/2018/S12/J7/173535163-5ab81c23a3594-standard1.mp4"
            }
          }
        },
        %Job{
          name: "download_ftp",
          params: %{
            "destination" => %{
              "path" => "/2018/S12/J7/173535163-5ab81c23a3594-qad.mp4"
            }
          }
        },
        %Job{
          name: "download_ftp",
          params: %{
            "destination" => %{
              "path" => "/2018/S12/J7/173535163-5ab81c23a3594-qaa.mp4"
            }
          }
        },
        %Job{
          name: "audio_extraction",
          params: %{
            "destination" => %{
              "paths" => ["/2018/S12/J7/173535163-5ab81c23a3594-fra.mp4"]
            }
          }
        }
      ]
    }

    step = %{
      "parameters" => [
        %{
          "id" => "segment_duration",
          "value" => 20000
        },
        %{
          "id" => "fragment_duration",
          "value" => 60000
        }
      ]
    }

    result = GenerateDash.build_step_parameters(workflow, step)
    assert result == {
      :ok,
      %{
        name: "generate_dash",
        params: %{
          kind: "generate_dash",
          options: %{
            "-out": "/tmp/ftp_francetv/dash/reference_id/manifest.mpd",
            "-profile": "onDemand",
            "-rap": true,
            "-url-template": true,
            "-dash": 20000,
            "-frag": 60000
          },
          requirements: %{
            paths: [
              "/2018/S12/J7/173535163-5ab81c23a3594-fra.mp4",
              "/2018/S12/J7/173535163-5ab81c23a3594-qaa.mp4",
              "/2018/S12/J7/173535163-5ab81c23a3594-qad.mp4",
              "/2018/S12/J7/173535163-5ab81c23a3594-standard1.mp4"
            ]
          },
          source: %{
            paths: [
              "/2018/S12/J7/173535163-5ab81c23a3594-fra.mp4#audio:id=a1",
              "/2018/S12/J7/173535163-5ab81c23a3594-qaa.mp4#audio:id=a2",
              "/2018/S12/J7/173535163-5ab81c23a3594-qad.mp4#audio:id=a3",
              "/2018/S12/J7/173535163-5ab81c23a3594-standard1.mp4#video:id=v5"
            ]
          }
        },
        workflow_id: 666
      }
    }
  end
end
