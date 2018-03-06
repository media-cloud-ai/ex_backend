defmodule ExSubtilBackendWeb.Docker.ContainersView do
  use ExSubtilBackendWeb, :view
  alias ExSubtilBackendWeb.Docker.ContainersView

  def render("index.json", %{containers: containers}) do
    %{
      data: render_many(containers, ContainersView, "container.json"),
      total: length(containers)
    }
  end

  def render("container.json", %{containers: container}) do
    %{
      id: container.id,
      names: container.names,
      image: container.image,
      state: container.state,
      status: container.status,
      docker_host_config: container.docker_host_config
    }
  end

  def render("creation.json", %{response: response}) do
    %{
      id: response["Id"],
      message: response["message"],
      warning: response["Warnings"]
    }
  end
end
