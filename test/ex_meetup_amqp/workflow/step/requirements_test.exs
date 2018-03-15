defmodule ExSubtilBackend.Workflow.Step.RequirementsTest do
  use ExUnit.Case

  alias ExSubtilBackend.Workflow.Step.Requirements
  doctest Requirements


  test "get path exists" do
    requirements = Requirements.get_path_exists("/path/to/hello-world.thing")
    assert %{paths: ["/path/to/hello-world.thing"]} == requirements

    requirements = Requirements.get_path_exists(requirements, "/path/to/some.thing")
    assert %{paths: ["/path/to/hello-world.thing", "/path/to/some.thing"]} == requirements

    requirements = Requirements.get_path_exists(["/path/to/hello-world.thing", "/path/to/some.thing"])
    assert %{paths: ["/path/to/hello-world.thing", "/path/to/some.thing"]} == requirements
  end

  test "get first dash quality exists" do
    requirements = Requirements.get_first_dash_quality_path_exists("/path/to/hello-world.thing")
    assert %{paths: ["/path/to/hello-standard1.mp4"]} == requirements

    requirements = Requirements.get_first_dash_quality_path_exists(%{foo: "bar"}, "/path/to/hello-world.thing")
    assert %{paths: ["/path/to/hello-standard1.mp4"], foo: "bar"} == requirements

    requirements = Requirements.get_first_dash_quality_path_exists(requirements, "/path/to/foo-bar.some")
    assert %{paths: ["/path/to/hello-standard1.mp4", "/path/to/foo-standard1.mp4"], foo: "bar"} == requirements
  end

  test "get first dash quality exists error" do
     assert_raise(ArgumentError, fn -> Requirements.get_first_dash_quality_path_exists("/path/to/some.thing") end)
  end

end
