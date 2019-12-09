defmodule Mix.Tasks.GenerateDocumentation do
  @moduledoc false

  use Mix.Task

  @shortdoc "Wrote the BlueBird documentation into json file"
  def run(_) do
    BlueBird.ConnLogger.start_link()
    BlueBird.start()

    {:ok, file} = File.open("documentation.json", [:write])

    documentation =
      BlueBird.Generator.run()
      |> Map.delete(:contact)
      |> Map.delete(:license)
      |> Poison.encode!()

    IO.binwrite(file, documentation)
    File.close(file)
  end
end
