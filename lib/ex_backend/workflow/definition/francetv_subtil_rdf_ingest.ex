defmodule ExBackend.Workflow.Definition.FrancetvSubtilRdfIngest do
  def get_definition() do
    %{
      steps: [
        %{
          id: 1,
          name: "push_rdf",
          enable: true
        }
      ]
    }
  end
end
