defmodule ExBackend.Workflow.Definition.FrancetvSubtilRdfIngest do
  def get_definition() do
    %{
      steps: [
        %{
          id: 1,
          name: "push_rdf",
          enable: true,
          parameters: [
            %{
              id: "perfect_memory_username",
              type: "credential",
              default: "PERFECT_MEMORY_USERNAME",
              value: "PERFECT_MEMORY_USERNAME"
            },
            %{
              id: "perfect_memory_password",
              type: "credential",
              default: "PERFECT_MEMORY_PASSWORD",
              value: "PERFECT_MEMORY_PASSWORD"
            },
            %{
              id: "perfect_memory_endpoint",
              type: "credential",
              default: "PERFECT_MEMORY_ENDPOINT",
              value: "PERFECT_MEMORY_ENDPOINT"
            },
            %{
              id: "perfect_memory_event_name",
              type: "string",
              value: "push_rdf_infos"
            }
          ]
        }
      ]
    }
  end
end
