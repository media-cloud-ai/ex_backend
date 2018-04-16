defmodule ExSubtilBackend.Docker.Container do
  alias RemoteDockers.ContainerConfig

  def build_config(params) do
    image_name = Map.get(params, "image", nil)
    container_config = ContainerConfig.new(image_name)

    container_config =
      Map.get(params, "volumes", [])
      |> add_volumes(container_config)

    container_config =
      Map.get(params, "environment", %{})
      |> Map.to_list()
      |> add_env_var(container_config)

    container_config
  end

  defp add_volumes([], config), do: config

  defp add_volumes([volume | volumes], config) do
    config =
      config
      |> ContainerConfig.add_mount_point(volume["host"], volume["container"])

    add_volumes(volumes, config)
  end

  defp add_env_var([], config), do: config

  defp add_env_var([{key, value} | vars], config) do
    config =
      config
      |> ContainerConfig.add_env(key, value)

    add_env_var(vars, config)
  end
end
