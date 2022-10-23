defmodule ExBackendWeb.OpenApiSchemas.Amqp.Connections do
  @moduledoc false

  alias ExBackendWeb.OpenApiSchemas.Amqp.Amqp
  alias OpenApiSpex.Schema

  defmodule Connection do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "Connection",
      description: "A RabbitMQ connection",
      type: :object,
      properties: %{
        ssl_protocol: %Schema{type: :string},
        peer_cert_subject: %Schema{type: :string},
        send_oct: %Schema{type: :integer},
        peer_cert_issuer: %Schema{type: :string},
        channels: %Schema{type: :integer},
        garbage_collection: Amqp.GarbageCollection.schema(),
        peer_port: %Schema{type: :integer},
        type: %Schema{type: :string},
        user: %Schema{type: :string},
        auth_mechanism: %Schema{type: :string},
        node: %Schema{type: :string},
        vhost: %Schema{type: :string},
        send_pend: %Schema{type: :integer},
        ssl: %Schema{type: :bool},
        send_cnt: %Schema{type: :integer},
        host: %Schema{type: :string},
        ssl_key_exchange: %Schema{type: :string},
        send_oct_details: Amqp.Rate.schema(),
        ssl_hash: %Schema{type: :string},
        port: %Schema{type: :integer},
        peer_cert_validity: %Schema{type: :string},
        connected_at: %Schema{type: :integer},
        reductions_details: Amqp.Rate.schema(),
        ssl_cipher: %Schema{type: :string},
        peer_host: %Schema{type: :string},
        client_properties: Amqp.Client.schema(),
        recv_oct: %Schema{type: :integer},
        recv_oct_details: Amqp.Rate.schema(),
        user_who_performed_action: %Schema{type: :string},
        timeout: %Schema{type: :integer},
        frame_max: %Schema{type: :integer},
        protocol: %Schema{type: :string},
        channel_max: %Schema{type: :integer},
        recv_cnt: %Schema{type: :integer},
        name: %Schema{type: :string},
        reductions: %Schema{type: :string},
        state: %Schema{type: :integer}
      },
      example: %{
        "ssl_protocol" => nil,
        "peer_cert_subject" => nil,
        "send_oct" => 420_500,
        "peer_cert_issuer" => nil,
        "channels" => 1,
        "garbage_collection" => %{
          "fullsweep_after" => 65_535,
          "max_heap_size" => 0,
          "min_bin_vheap_size" => 46_422,
          "min_heap_size" => 233,
          "minor_gcs" => 112
        },
        "peer_port" => 36_322,
        "type" => "network",
        "user" => "mca_rmquser",
        "auth_mechanism" => "PLAIN",
        "node" => "rabbit",
        "vhost" => "media_cloud_ai",
        "send_pend" => 0,
        "ssl" => false,
        "send_cnt" => 52_486,
        "host" => "10.233.123.141",
        "ssl_key_exchange" => nil,
        "send_oct_details" => %{
          "rate" => 1.6
        },
        "ssl_hash" => nil,
        "port" => 5672,
        "peer_cert_validity" => nil,
        "connected_at" => 1_666_276_133_178,
        "reductions_details" => %{
          "rate" => 220.0
        },
        "ssl_cipher" => nil,
        "peer_host" => "10.233.106.63",
        "client_properties" => %{
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
        },
        "recv_oct" => 3_037_840,
        "recv_oct_details" => %{
          "rate" => 21.4
        },
        "user_who_performed_action" => "rmquser",
        "timeout" => 10,
        "frame_max" => 131_072,
        "protocol" => "AMQP 0-9-1",
        "channel_max" => 2047,
        "recv_cnt" => 52_559,
        "name" => "0.0.0.0:36_322 -> 0.0.0.0:5672",
        "reductions" => 55_132_539,
        "state" => "running"
      }
    })
  end

  defmodule Connections do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "Connections",
      description: "A collection of Connections",
      type: :array,
      items: Connection.schema(),
      examples: [
        %{
          "ssl_protocol" => nil,
          "peer_cert_subject" => nil,
          "send_oct" => 420_500,
          "peer_cert_issuer" => nil,
          "channels" => 1,
          "garbage_collection" => %{
            "fullsweep_after" => 65_535,
            "max_heap_size" => 0,
            "min_bin_vheap_size" => 46_422,
            "min_heap_size" => 233,
            "minor_gcs" => 112
          },
          "peer_port" => 36_322,
          "type" => "network",
          "user" => "mca_rmquser",
          "auth_mechanism" => "PLAIN",
          "node" => "rabbit",
          "vhost" => "media_cloud_ai",
          "send_pend" => 0,
          "ssl" => false,
          "send_cnt" => 52_486,
          "host" => "10.233.123.141",
          "ssl_key_exchange" => nil,
          "send_oct_details" => %{
            "rate" => 1.6
          },
          "ssl_hash" => nil,
          "port" => 5672,
          "peer_cert_validity" => nil,
          "connected_at" => 1_666_276_133_178,
          "reductions_details" => %{
            "rate" => 220.0
          },
          "ssl_cipher" => nil,
          "peer_host" => "10.233.106.63",
          "client_properties" => %{
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
          },
          "recv_oct" => 3_037_840,
          "recv_oct_details" => %{
            "rate" => 21.4
          },
          "user_who_performed_action" => "rmquser",
          "timeout" => 10,
          "frame_max" => 131_072,
          "protocol" => "AMQP 0-9-1",
          "channel_max" => 2047,
          "recv_cnt" => 52_559,
          "name" => "0.0.0.0:36_322 -> 0.0.0.0:5672",
          "reductions" => 55_132_539,
          "state" => "running"
        }
      ]
    })
  end
end
