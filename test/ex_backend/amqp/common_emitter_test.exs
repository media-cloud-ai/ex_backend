defmodule ExBackend.CommonEmitterTest do
  use ExUnit.Case

  alias ExBackend.Amqp.CommonEmitter

  test "remove filter parameter from message parameters" do
    message = %{
      parameters: [
        %{
          "id" => "some_filter",
          "type" => "filter",
          "default" => %{ends_with: ".txt"},
          "value" => %{ends_with: ".txt"}
        }
      ]
    }

    message = CommonEmitter.check_message_parameters(message)
    assert message.parameters == []
  end

  test "remove filter parameter among other from message parameters" do
    message = %{
      parameters: [
        %{
          "id" => "parameter",
          "type" => "string",
          "value" => "value"
        },
        %{
          "id" => "some_filter",
          "type" => "filter",
          "default" => %{ends_with: ".txt"},
          "value" => %{ends_with: ".txt"}
        }
      ]
    }

    message = CommonEmitter.check_message_parameters(message)
    assert message.parameters == [%{"id" => "parameter", "type" => "string", "value" => "value"}]
  end

  test "remove all filter parameters from message parameters" do
    message = %{
      parameters: [
        %{
          "id" => "some_filter",
          "type" => "filter",
          "default" => %{ends_with: ".txt"},
          "value" => %{ends_with: ".txt"}
        },
        %{
          "id" => "other_filter",
          "type" => "filter",
          "default" => %{ends_with: ".log"},
          "value" => %{ends_with: ".log"}
        }
      ]
    }

    message = CommonEmitter.check_message_parameters(message)
    assert message.parameters == []
  end
end
