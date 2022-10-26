defmodule ExBackendWeb.OpenApiSchemas.Amqp.Queues do
  @moduledoc false

  alias ExBackendWeb.OpenApiSchemas.Amqp.Amqp
  alias OpenApiSpex.Schema

  defmodule Queue do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "Queue",
      description: "A RabbitMQ queue",
      type: :object,
      properties: %{
        messages_persistent: %Schema{type: :integer},
        messages_unacknowledged_details: Amqp.Rate.schema(),
        garbage_collection: Amqp.GarbageCollection.schema(),
        memory: %Schema{type: :integer},
        message_bytes_ram: %Schema{type: :integer},
        consumers: %Schema{type: :integer},
        backing_queue_status: Amqp.Status.schema(),
        recoverable_slaves: %Schema{type: :integer},
        messages_paged_out: %Schema{type: :integer},
        type: %Schema{type: :string},
        message_bytes: %Schema{type: :integer},
        node: %Schema{type: :string},
        vhost: %Schema{type: :string},
        exclusive_consumer_tag: %Schema{type: :string},
        auto_delete: %Schema{type: :bool},
        messages: %Schema{type: :integer},
        policy: %Schema{type: :string},
        message_bytes_unacknowledged: %Schema{type: :integer},
        messages_unacknowledged: %Schema{type: :integer},
        consumer_utilisation: %Schema{type: :integer},
        messages_unacknowledged_ram: %Schema{type: :integer},
        message_bytes_paged_out: %Schema{type: :integer},
        single_active_consumer_tag: %Schema{type: :integer},
        head_message_timestamp: %Schema{type: :integer},
        messages_ready_details: Amqp.Rate.schema(),
        messages_ready: %Schema{type: :integer},
        durable: %Schema{type: :bool},
        reductions_details: Amqp.Rate.schema(),
        operator_policy: %Schema{type: :string},
        idle_since: %Schema{type: :string},
        consumer_capacity: %Schema{type: :integer},
        message_bytes_ready: %Schema{type: :integer},
        messages_ready_ram: %Schema{type: :integer},
        message_bytes_persistent: %Schema{type: :integer},
        messages_details: Amqp.Rate.schema(),
        arguments: %Schema{type: :object},
        name: %Schema{type: :string},
        reductions: %Schema{type: :integer},
        effective_policy_definition: %Schema{type: :object},
        state: %Schema{type: :string},
        messages_ram: %Schema{type: :integer}
      },
      example: %{
        "messages_persistent" => 0,
        "messages_unacknowledged_details" => %{
          "rate" => 0.0
        },
        "garbage_collection" => %{
          "fullsweep_after" => 65_535,
          "max_heap_size" => 0,
          "min_bin_vheap_size" => 46_422,
          "min_heap_size" => 233,
          "minor_gcs" => 13_154
        },
        "memory" => 13_464,
        "message_bytes_ram" => 0,
        "consumers" => 0,
        "backing_queue_status" => %{
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
        },
        "recoverable_slaves" => nil,
        "messages_paged_out" => 0,
        "type" => "classic",
        "message_bytes" => 0,
        "node" => "rabbit",
        "vhost" => "media_cloud_ai",
        "exclusive_consumer_tag" => nil,
        "auto_delete" => false,
        "messages" => 0,
        "policy" => nil,
        "message_bytes_unacknowledged" => 0,
        "messages_unacknowledged" => 0,
        "consumer_utilisation" => 0,
        "messages_unacknowledged_ram" => 0,
        "message_bytes_paged_out" => 0,
        "single_active_consumer_tag" => nil,
        "head_message_timestamp" => nil,
        "messages_ready_details" => %{
          "rate" => 0.0
        },
        "messages_ready" => 0,
        "durable" => true,
        "reductions_details" => %{
          "rate" => 0.0
        },
        "operator_policy" => nil,
        "idle_since" => "2022-10-23 15:02:52",
        "consumer_capacity" => 0,
        "message_bytes_ready" => 0,
        "messages_ready_ram" => 0,
        "message_bytes_persistent" => 0,
        "messages_details" => %{
          "rate" => 0.0
        },
        "exclusive" => false,
        "arguments" => %{},
        "name" => "direct_messaging_not_found",
        "reductions" => 16_935_691,
        "effective_policy_definition" => %{},
        "state" => "running",
        "messages_ram" => 0
      }
    })
  end

  defmodule Queues do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "Queues",
      description: "A collection of Queues",
      type: :array,
      items: Queue.schema(),
      examples: [
        %{
          "messages_persistent" => 0,
          "messages_unacknowledged_details" => %{
            "rate" => 0.0
          },
          "garbage_collection" => %{
            "fullsweep_after" => 65_535,
            "max_heap_size" => 0,
            "min_bin_vheap_size" => 46_422,
            "min_heap_size" => 233,
            "minor_gcs" => 13_154
          },
          "memory" => 13_464,
          "message_bytes_ram" => 0,
          "consumers" => 0,
          "backing_queue_status" => %{
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
          },
          "recoverable_slaves" => nil,
          "messages_paged_out" => 0,
          "type" => "classic",
          "message_bytes" => 0,
          "node" => "rabbit",
          "vhost" => "media_cloud_ai",
          "exclusive_consumer_tag" => nil,
          "auto_delete" => false,
          "messages" => 0,
          "policy" => nil,
          "message_bytes_unacknowledged" => 0,
          "messages_unacknowledged" => 0,
          "consumer_utilisation" => 0,
          "messages_unacknowledged_ram" => 0,
          "message_bytes_paged_out" => 0,
          "single_active_consumer_tag" => nil,
          "head_message_timestamp" => nil,
          "messages_ready_details" => %{
            "rate" => 0.0
          },
          "messages_ready" => 0,
          "durable" => true,
          "reductions_details" => %{
            "rate" => 0.0
          },
          "operator_policy" => nil,
          "idle_since" => "2022-10-23 15:02:52",
          "consumer_capacity" => 0,
          "message_bytes_ready" => 0,
          "messages_ready_ram" => 0,
          "message_bytes_persistent" => 0,
          "messages_details" => %{
            "rate" => 0.0
          },
          "exclusive" => false,
          "arguments" => %{},
          "name" => "direct_messaging_not_found",
          "reductions" => 16_935_691,
          "effective_policy_definition" => %{},
          "state" => "running",
          "messages_ram" => 0
        }
      ]
    })
  end
end
