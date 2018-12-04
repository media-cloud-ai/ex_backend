defmodule ExBackend.Workflow.Step.GenerateDashTest do
  use ExUnit.Case
  alias ExBackend.Workflow.Step.GenerateDash
  alias ExBackend.Workflows.Workflow
  alias ExBackend.Jobs.Job

  doctest GenerateDash

  test "skipped step" do
    workflow = %Workflow{
      id: 666,
      reference: "reference_id",
      flow: %{steps: []},
      jobs: []
    }

    step = %{
      "id" => 0,
      "parameters" => []
    }

    result = GenerateDash.build_step_parameters(workflow, step, 0)
    assert {:skipped, nil} == result
  end

  test "video only" do
    workflow = %Workflow{
      id: 666,
      reference: "reference_id",
      flow: %{steps: []},
      jobs: [
        %Job{
          id: 0,
          step_id: 555,
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
      "id" => 0,
      "parent_ids" => [555],
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

    result = GenerateDash.build_step_parameters(workflow, step, 0)

    assert {
             :ok,
             %{
               name: "generate_dash",
               params: %{
                 list: [
                  %{
                    "id" => "segment_duration",
                    "value" => 20000
                  }, %{
                    "id" => "fragment_duration",
                    "value" => 60000
                  }, %{
                    "id" => "action",
                    "type" => "string",
                    "value" => "generate_dash"
                  }, %{
                    "id" => "source_paths",
                    "type" => "string",
                    "value" => [
                      "/2018/S12/J7/173535163-5ab81c23a3594-standard3.mp4#video:id=v3"
                    ]
                  }, %{
                    "id" => "destination_path",
                    "type" => "string",
                    "value" => "/data/666/dash/manifest.mpd"
                  }, %{
                    "id" => "requirements",
                    "type" => "requirements",
                    "value" => %{
                      paths: [
                        "/2018/S12/J7/173535163-5ab81c23a3594-standard3.mp4"
                      ]
                    }
                  }, %{
                    "id" => "profile",
                    "type" => "string",
                    "value" => "onDemand"
                  }, %{
                    "id" => "rap",
                    "type" => "boolean",
                    "value" => true
                  }, %{
                    "id" => "url_template",
                    "type" => "boolean",
                    "value" => true
                  }
                 ]
               },
               workflow_id: 666,
               step_id: 0
             }
           } == result
  end

  test "video with 1 audio" do
    workflow = %Workflow{
      id: 666,
      reference: "reference_id",
      flow: %{steps: []},
      jobs: [
        %Job{
          name: "download_ftp",
          step_id: 3,
          params: %{
            "destination" => %{
              "path" => "/2018/S12/J7/173535163-5ab81c23a3594-standard1.mp4"
            }
          }
        },
        %Job{
          name: "audio_extraction",
          step_id: 4,
          params: %{
            "destination" => %{
              "paths" => ["/2018/S12/J7/173535163-5ab81c23a3594-fra.mp4"]
            }
          }
        }
      ]
    }

    step = %{
      "id" => 0,
      "parent_ids" => [3, 4],
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

    result = GenerateDash.build_step_parameters(workflow, step, 0)

    assert {
             :ok,
             %{
               name: "generate_dash",
               params: %{
                 list: [
                  %{
                    "id" => "segment_duration",
                    "value" => 20000
                  }, %{
                    "id" => "fragment_duration",
                    "value" => 60000
                  }, %{
                    "id" => "action",
                    "type" => "string",
                    "value" => "generate_dash"
                  }, %{
                    "id" => "source_paths",
                    "type" => "string",
                    "value" => [
                      "/2018/S12/J7/173535163-5ab81c23a3594-fra.mp4#audio:id=a1",
                      "/2018/S12/J7/173535163-5ab81c23a3594-standard1.mp4#video:id=v5"
                    ]
                  }, %{
                    "id" => "destination_path",
                    "type" => "string",
                    "value" => "/data/666/dash/manifest.mpd"
                  }, %{
                    "id" => "requirements",
                    "type" => "requirements",
                    "value" => %{
                      paths: [
                        "/2018/S12/J7/173535163-5ab81c23a3594-fra.mp4",
                        "/2018/S12/J7/173535163-5ab81c23a3594-standard1.mp4"
                      ]
                    }
                  }, %{
                    "id" => "profile",
                    "type" => "string",
                    "value" => "onDemand"
                  }, %{
                    "id" => "rap",
                    "type" => "boolean",
                    "value" => true
                  }, %{
                    "id" => "url_template",
                    "type" => "boolean",
                    "value" => true
                  }
                 ]
               },
               workflow_id: 666,
               step_id: 0
             }
           } == result
  end

  test "video with 1 audio and 1 Audio Description" do
    workflow = %Workflow{
      id: 666,
      reference: "reference_id",
      flow: %{steps: []},
      jobs: [
        %Job{
          name: "download_ftp",
          step_id: 0,
          params: %{
            "destination" => %{
              "path" => "/2018/S12/J7/173535163-5ab81c23a3594-standard1.mp4"
            }
          }
        },
        %Job{
          name: "download_ftp",
          step_id: 1,
          params: %{
            "destination" => %{
              "path" => "/2018/S12/J7/173535163-5ab81c23a3594-qad.mp4"
            }
          }
        },
        %Job{
          name: "audio_extraction",
          step_id: 2,
          params: %{
            "destination" => %{
              "paths" => ["/2018/S12/J7/173535163-5ab81c23a3594-fra.mp4"]
            }
          }
        }
      ]
    }

    step = %{
      "id" => 4,
      "parent_ids" => [0, 1, 2],
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

    result = GenerateDash.build_step_parameters(workflow, step, 0)

    assert {
             :ok,
             %{
               name: "generate_dash",
               params: %{
                 list: [
                  %{
                    "id" => "segment_duration",
                    "value" => 20000
                  }, %{
                    "id" => "fragment_duration",
                    "value" => 60000
                  }, %{
                    "id" => "action",
                    "type" => "string",
                    "value" => "generate_dash"
                  }, %{
                    "id" => "source_paths",
                    "type" => "string",
                    "value" => [
                      "/2018/S12/J7/173535163-5ab81c23a3594-fra.mp4#audio:id=a1",
                      "/2018/S12/J7/173535163-5ab81c23a3594-qad.mp4#audio:id=a2",
                      "/2018/S12/J7/173535163-5ab81c23a3594-standard1.mp4#video:id=v5"
                    ]
                  }, %{
                    "id" => "destination_path",
                    "type" => "string",
                    "value" => "/data/666/dash/manifest.mpd"
                  }, %{
                    "id" => "requirements",
                    "type" => "requirements",
                    "value" => %{
                      paths: [
                        "/2018/S12/J7/173535163-5ab81c23a3594-fra.mp4",
                        "/2018/S12/J7/173535163-5ab81c23a3594-qad.mp4",
                        "/2018/S12/J7/173535163-5ab81c23a3594-standard1.mp4"
                      ]
                    }
                  }, %{
                    "id" => "profile",
                    "type" => "string",
                    "value" => "onDemand"
                  }, %{
                    "id" => "rap",
                    "type" => "boolean",
                    "value" => true
                  }, %{
                    "id" => "url_template",
                    "type" => "boolean",
                    "value" => true
                  }
                ]
               },
               workflow_id: 666,
               step_id: 0
             }
           } == result
  end

  test "video with 1 audio and 1 original version" do
    workflow = %Workflow{
      id: 666,
      reference: "reference_id",
      flow: %{steps: []},
      jobs: [
        %Job{
          name: "download_ftp",
          step_id: 0,
          params: %{
            "destination" => %{
              "path" => "/2018/S12/J7/173535163-5ab81c23a3594-standard1.mp4"
            }
          }
        },
        %Job{
          name: "download_ftp",
          step_id: 1,
          params: %{
            "destination" => %{
              "path" => "/2018/S12/J7/173535163-5ab81c23a3594-qaa.mp4"
            }
          }
        },
        %Job{
          name: "audio_extraction",
          step_id: 2,
          params: %{
            "destination" => %{
              "paths" => ["/2018/S12/J7/173535163-5ab81c23a3594-fra.mp4"]
            }
          }
        }
      ]
    }

    step = %{
      "id" => 0,
      "parent_ids" => [0, 1, 2],
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

    result = GenerateDash.build_step_parameters(workflow, step, 0)

    assert {
             :ok,
             %{
               name: "generate_dash",
               params: %{
                 list: [
                  %{
                    "id" => "segment_duration",
                    "value" => 20000
                  }, %{
                    "id" => "fragment_duration",
                    "value" => 60000
                  }, %{
                    "id" => "action",
                    "type" => "string",
                    "value" => "generate_dash"
                  }, %{
                    "id" => "source_paths",
                    "type" => "string",
                    "value" => ["/2018/S12/J7/173535163-5ab81c23a3594-fra.mp4#audio:id=a1", "/2018/S12/J7/173535163-5ab81c23a3594-qaa.mp4#audio:id=a2", "/2018/S12/J7/173535163-5ab81c23a3594-standard1.mp4#video:id=v5"]
                  }, %{
                    "id" => "destination_path",
                    "type" => "string",
                    "value" => "/data/666/dash/manifest.mpd"
                  }, %{
                    "id" => "requirements",
                    "type" => "requirements",
                    "value" => %{
                      paths: [
                        "/2018/S12/J7/173535163-5ab81c23a3594-fra.mp4",
                        "/2018/S12/J7/173535163-5ab81c23a3594-qaa.mp4",
                        "/2018/S12/J7/173535163-5ab81c23a3594-standard1.mp4"
                      ]
                    }
                  }, %{
                    "id" => "profile",
                    "type" => "string",
                    "value" => "onDemand"
                  }, %{
                    "id" => "rap",
                    "type" => "boolean",
                    "value" => true
                  }, %{
                    "id" => "url_template",
                    "type" => "boolean",
                    "value" => true
                  }
                ]
               },
               workflow_id: 666,
               step_id: 0
             }
           } == result
  end

  test "video with 1 audio and 1 original version and 1 audio description" do
    workflow = %Workflow{
      id: 666,
      reference: "reference_id",
      flow: %{steps: []},
      jobs: [
        %Job{
          step_id: 0,
          name: "download_ftp",
          params: %{
            "destination" => %{
              "path" => "/2018/S12/J7/173535163-5ab81c23a3594-standard1.mp4"
            }
          }
        },
        %Job{
          step_id: 0,
          name: "download_ftp",
          params: %{
            "destination" => %{
              "path" => "/2018/S12/J7/173535163-5ab81c23a3594-qad.mp4"
            }
          }
        },
        %Job{
          step_id: 0,
          name: "download_ftp",
          params: %{
            "destination" => %{
              "path" => "/2018/S12/J7/173535163-5ab81c23a3594-qaa.mp4"
            }
          }
        },
        %Job{
          step_id: 1,
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
      "id" => 0,
      "parent_ids" => [0, 1],
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

    result = GenerateDash.build_step_parameters(workflow, step, 0)

    assert {
             :ok,
             %{
               name: "generate_dash",
               params: %{
                 list: [
                  %{
                    "id" => "segment_duration",
                    "value" => 20000
                  }, %{
                    "id" => "fragment_duration",
                    "value" => 60000
                  }, %{
                    "id" => "action",
                    "type" => "string",
                    "value" => "generate_dash"
                  }, %{
                    "id" => "source_paths",
                    "type" => "string",
                    "value" => [
                      "/2018/S12/J7/173535163-5ab81c23a3594-fra.mp4#audio:id=a1",
                      "/2018/S12/J7/173535163-5ab81c23a3594-qaa.mp4#audio:id=a2",
                      "/2018/S12/J7/173535163-5ab81c23a3594-qad.mp4#audio:id=a3",
                      "/2018/S12/J7/173535163-5ab81c23a3594-standard1.mp4#video:id=v5"
                    ]
                  }, %{
                    "id" => "destination_path",
                    "type" => "string",
                    "value" => "/data/666/dash/manifest.mpd"
                  }, %{
                    "id" => "requirements",
                    "type" => "requirements",
                    "value" => %{
                      paths: [
                        "/2018/S12/J7/173535163-5ab81c23a3594-fra.mp4",
                        "/2018/S12/J7/173535163-5ab81c23a3594-qaa.mp4",
                        "/2018/S12/J7/173535163-5ab81c23a3594-qad.mp4",
                        "/2018/S12/J7/173535163-5ab81c23a3594-standard1.mp4"
                      ]
                    }
                  }, %{
                    "id" => "profile",
                    "type" => "string",
                    "value" => "onDemand"
                  }, %{
                    "id" => "rap",
                    "type" => "boolean",
                    "value" => true
                  }, %{
                    "id" => "url_template",
                    "type" => "boolean",
                    "value" => true
                  }
                ]
               },
               workflow_id: 666,
               step_id: 0
             }
           } == result
  end
end
