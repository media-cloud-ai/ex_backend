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

  test "get required first file" do
    dir_path = "/tmp/test_folder/"
    path2 = dir_path <> "ijklmnop.some"
    path1 = dir_path <> "abcdefgh.thing"
    File.mkdir_p!("/tmp/test_folder/")
    File.touch!(path1)
    File.touch!(path2)

    requirements = Requirements.get_required_first_file_path(path1)
    assert %{} == requirements

    requirements = Requirements.get_required_first_file_path(path2)
    assert %{paths: [path1]} == requirements

    requirements = Requirements.get_required_first_file_path(%{foo: "bar"}, path2)
    assert %{paths: [path1], foo: "bar"} == requirements

    requirements = Requirements.get_required_first_file_path(requirements, path2)
    assert %{paths: [path1], foo: "bar"} == requirements
  end

end
