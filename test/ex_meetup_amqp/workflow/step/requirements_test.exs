defmodule ExSubtilBackend.Workflow.Step.RequirementsTest do
  use ExUnit.Case

  alias ExSubtilBackend.Workflow.Step.Requirements
  doctest Requirements


  test "add required paths" do
    requirements = Requirements.add_required_paths("/path/to/hello-world.thing")
    assert %{paths: ["/path/to/hello-world.thing"]} == requirements

    requirements = Requirements.add_required_paths("/path/to/some.thing", requirements)
    assert %{paths: ["/path/to/hello-world.thing", "/path/to/some.thing"]} == requirements

    requirements = Requirements.add_required_paths(["/path/to/hello-world.thing", "/path/to/some.thing"])
    assert %{paths: ["/path/to/hello-world.thing", "/path/to/some.thing"]} == requirements

    requirements = Requirements.add_required_paths(["/path/to/some.thing", "/path/to/other.thing"], requirements)
    assert %{paths: ["/path/to/hello-world.thing", "/path/to/some.thing", "/path/to/other.thing"]} == requirements
  end
end
