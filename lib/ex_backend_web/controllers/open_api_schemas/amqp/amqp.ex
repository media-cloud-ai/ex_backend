defmodule ExBackendWeb.OpenApiSchemas.Amqp.Amqp do
  @moduledoc false

  alias OpenApiSpex.Schema

  defmodule Rate do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "Rate",
      description: "RabbitMQ Rate",
      type: :object,
      properties: %{
        rate: %Schema{type: :number}
      },
      example: %{
        "rate" => 0.0
      }
    })
  end

  defmodule GarbageCollection do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "GarbageCollection",
      description: "RabbitMQ Garbage Collection",
      type: :object,
      properties: %{
        fullsweep_after: %Schema{type: :integer},
        max_heap_size: %Schema{type: :integer},
        min_bin_vheap_size: %Schema{type: :integer},
        min_heap_size: %Schema{type: :integer},
        minor_gcs: %Schema{type: :integer}
      },
      example: %{
        "fullsweep_after" => 65_535,
        "max_heap_size" => 0,
        "min_bin_vheap_size" => 46_422,
        "min_heap_size" => 233,
        "minor_gcs" => 13_154
      }
    })
  end

  defmodule Status do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "Status",
      description: "RabbitMQ Status",
      type: :object,
      properties: %{
        avg_ack_egress_rate: %Schema{type: :number},
        avg_ack_ingress_rate: %Schema{type: :number},
        avg_egress_rate: %Schema{type: :number},
        avg_ingress_rate: %Schema{type: :number},
        delta: %Schema{type: :array, items: %Schema{type: :string}},
        len: %Schema{type: :integer},
        mode: %Schema{type: :string},
        next_seq_id: %Schema{type: :integer},
        q1: %Schema{type: :integer},
        q2: %Schema{type: :integer},
        q3: %Schema{type: :integer},
        q4: %Schema{type: :integer},
        target_ram_count: %Schema{type: :string}
      },
      example: %{
        "avg_ack_egress_rate" => 0.0,
        "avg_ack_ingress_rate" => 0.0,
        "avg_egress_rate" => 0.0,
        "avg_ingress_rate" => 0.0,
        "delta" => [
          "delta",
          "undefined",
          0,
          0,
          "undefined"
        ],
        "len" => 0,
        "mode" => "default",
        "next_seq_id" => 0,
        "q1" => 0,
        "q2" => 0,
        "q3" => 0,
        "q4" => 0,
        "target_ram_count" => "infinity"
      }
    })
  end

  defmodule Capabilities do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "Capabilities",
      description: "RabbitMQ Capabilities",
      type: :object,
      properties: %{
        authentication_failure_close: %Schema{type: :bool},
        basic: %Schema{type: :bool},
        "connection.blocked": %Schema{type: :bool},
        consumer_cancel_notify: %Schema{type: :bool},
        exchange_exchange_bindings: %Schema{type: :bool},
        publisher_confirms: %Schema{type: :bool}
      },
      example: %{
        "authentication_failure_close" => true,
        "basic.nack" => true,
        "connection.blocked" => true,
        "consumer_cancel_notify" => true,
        "exchange_exchange_bindings" => true,
        "publisher_confirms" => true
      }
    })
  end

  defmodule Client do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "Client",
      description: "RabbitMQ Client",
      type: :object,
      properties: %{
        capabilities: Capabilities.schema(),
        copyright: %Schema{type: :string},
        information: %Schema{type: :string},
        platform: %Schema{type: :string},
        product: %Schema{type: :string},
        version: %Schema{type: :string}
      },
      example: %{
        "capabilities" => %{
          "authentication_failure_close" => true,
          "basic.nack" => true,
          "connection.blocked" => true,
          "consumer_cancel_notify" => true,
          "exchange_exchange_bindings" => true,
          "publisher_confirms" => true
        },
        "copyright" => "Copyright (c) 2007-2021 VMware, Inc. or its affiliates.",
        "information" => "Licensed under the MPL.  See https://www.rabbitmq.com/",
        "platform" => "Erlang",
        "product" => "RabbitMQ",
        "version" => "3.9.23"
      }
    })
  end
end
