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
end
