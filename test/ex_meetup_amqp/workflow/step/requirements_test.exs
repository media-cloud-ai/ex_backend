defmodule ExSubtilBackend.Workflow.Step.RequirementsTest do
  use ExUnit.Case

  alias ExSubtilBackend.Workflow.Step.Requirements
  doctest Requirements


  test "get required paths" do
    requirements = Requirements.get_required_paths("/path/to/hello-world.thing")
    assert %{paths: ["/path/to/hello-world.thing"]} == requirements

    requirements = Requirements.get_required_paths(requirements, "/path/to/some.thing")
    assert %{paths: ["/path/to/hello-world.thing", "/path/to/some.thing"]} == requirements

    requirements = Requirements.get_required_paths(["/path/to/hello-world.thing", "/path/to/some.thing"])
    assert %{paths: ["/path/to/hello-world.thing", "/path/to/some.thing"]} == requirements

    requirements = Requirements.get_required_paths(requirements, ["/path/to/some.thing", "/path/to/other.thing"])
    assert %{paths: ["/path/to/hello-world.thing", "/path/to/some.thing", "/path/to/other.thing"]} == requirements
  end

  test "get required first dash quality" do
    requirements = Requirements.get_required_first_dash_quality_path("/path/to/hello-world.thing")
    assert %{paths: ["/path/to/hello-standard1.mp4"]} == requirements

    requirements = Requirements.get_required_first_dash_quality_path(%{foo: "bar"}, "/path/to/hello-world.thing")
    assert %{paths: ["/path/to/hello-standard1.mp4"], foo: "bar"} == requirements

    requirements = Requirements.get_required_first_dash_quality_path(requirements, "/path/to/foo-bar.some")
    assert %{paths: ["/path/to/hello-standard1.mp4", "/path/to/foo-standard1.mp4"], foo: "bar"} == requirements
  end

  test "get required first dash quality error" do
     assert_raise(ArgumentError, fn -> Requirements.get_required_first_dash_quality_path("/path/to/some.thing") end)
  end

end
