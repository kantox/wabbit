defmodule Wabbit.Exchange do
  @moduledoc """
  Functions to operate on Exchanges.
  """

  import Wabbit.Record

  @doc """
  Declares an Exchange. The default Exchange type is `direct`.

  AMQP 0-9-1 brokers provide four pre-declared exchanges:

  * Direct exchange: (empty string) or `amq.direct`
  * Fanout exchange: `amq.fanout`
  * Topic exchange: `amq.topic`
  * Headers exchange: `amq.match` (and `amq.headers` in RabbitMQ)

  Besides the exchange name and type, the following options can be used:

  # Options

    * `:durable` - If set, keeps the Exchange between restarts of the broker
    * `:auto_delete` - If set, deletes the Exchange once all queues unbind from it
    * `:passive` - If set, returns an error if the Exchange does not already exist
    * `:internal` - If set, the exchange may not be used directly by publishers,
    but only when bound to other exchanges. Internal exchanges are  used to
    construct wiring that is not visible to applications.
    * `:no_wait` - If set, the server will not respond to the method
    * `:arguments` - A set of arguments for the declaration
  """
  def declare(channel, exchange, type \\ :direct, options \\ []) do
    exchange_declare =
      exchange_declare(exchange:    exchange,
                       type:        Atom.to_string(type),
                       passive:     Keyword.get(options, :passive,     false),
                       durable:     Keyword.get(options, :durable,     false),
                       auto_delete: Keyword.get(options, :auto_delete, false),
                       internal:    Keyword.get(options, :internal,    false),
                       nowait:      Keyword.get(options, :no_wait,     false),
                       arguments:   Keyword.get(options, :arguments,   []))
    exchange_declare_ok() = :amqp_channel.call(channel, exchange_declare)
    :ok
  end

  @doc """
  Deletes an Exchange by name.

  When an Exchange is deleted all bindings to it are also deleted

  # Options

    * `:if_unused` - If set, the server will only delete the exchange
      if it has no queue bindings
    * `:no_wait` - If set, the server will not respond to the method
  """
  def delete(channel, exchange, options \\ []) do
    exchange_delete =
      exchange_delete(exchange:  exchange,
                      if_unused: Keyword.get(options, :if_unused, false),
                      nowait:    Keyword.get(options, :no_wait,   false))
    exchange_delete_ok() = :amqp_channel.call(channel, exchange_delete)
    :ok
  end

  @doc """
  Binds an Exchange to another Exchange or a Queue using the
  exchange.bind AMQP method (a RabbitMQ-specific extension)

  # Options

    * `:routing_key` - If set, specifies the routing key for the binding
    * `:no_wait` - If set, the server will not respond to the method
    * `:arguments` - A set of arguments for the binding
  """
  def bind(channel, destination, source, options \\ []) do
    exchange_bind =
      exchange_bind(destination: destination,
                    source:      source,
                    routing_key: Keyword.get(options, :routing_key, ""),
                    nowait:      Keyword.get(options, :no_wait,     false),
                    arguments:   Keyword.get(options, :arguments,   []))
    exchange_bind_ok() = :amqp_channel.call(channel, exchange_bind)
    :ok
  end

  @doc """
  Unbinds an Exchange from another Exchange or a Queue using the
  exchange.unbind AMQP method (a RabbitMQ-specific extension)

  # Options

    * `:routing_key` - If set, specifies the routing key for the unbind
    * `:no_wait` - If set, the server will not respond to the method
    * `:arguments` - A set of arguments for the unbind
  """
  def unbind(channel, destination, source, options \\ []) do
    exchange_unbind =
      exchange_unbind(destination: destination,
                      source:      source,
                      routing_key: Keyword.get(options, :routing_key, ""),
                      nowait:      Keyword.get(options, :no_wait,     false),
                      arguments:   Keyword.get(options, :arguments,   []))
    exchange_unbind_ok() = :amqp_channel.call(channel, exchange_unbind)
    :ok
  end

  @doc """
  Convenience function to declare an Exchange of type `direct`.
  """
  def direct(channel, exchange, options \\ []) do
    declare(channel, exchange, :direct, options)
  end

  @doc """
  Convenience function to declare an Exchange of type `fanout`.
  """
  def fanout(channel, exchange, options \\ []) do
    declare(channel, exchange, :fanout, options)
  end

  @doc """
  Convenience function to declare an Exchange of type `topic`.
  """
  def topic(channel, exchange, options \\ []) do
    declare(channel, exchange, :topic, options)
  end
end
