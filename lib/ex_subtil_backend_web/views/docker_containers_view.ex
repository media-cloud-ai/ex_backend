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
      id: container["Id"],
      names: container["Names"],
      image: container["Image"],
      state: container["State"],
      status: container["Status"],
      host: container["Host"]
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
