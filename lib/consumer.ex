defmodule Telegram.Consumer do
  use GenServer
  use AMQP

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], [])
  end

  @queue        "Telegram"
  @queue_error  "#{@queue}.error"
  @exchange     "#{@queue}.exchange"

  def init(_opts) do
    {:ok, connection} = AMQP.Connection.open(Telegram.Config.amqp_server_string)
    {:ok, channel} = AMQP.Channel.open(connection)
    setup_queue(channel)

    {:ok, _consumer_tag} = Basic.consume(channel, @queue)
    {:ok, channel}
  end

  def handle_info({:basic_consume_ok, %{consumer_tag: _consumer_tag}}, channel) do
    {:noreply, channel}
  end


  def handle_info({:basic_cancel, %{consumer_tag: _consumer_tag}}, channel) do
    {:stop, :normal, channel}
  end

  # Confirmation sent by the broker to the consumer process after a Basic.cancel
  def handle_info({:basic_cancel_ok, %{consumer_tag: _consumer_tag}}, channel) do
    {:noreply, channel}
  end

  def handle_info({:basic_deliver, message, _meta}, _channel) do
    IO.inspect(message)
    deliver( Jason.decode!(message) )
  end

  def deliver( message ) do
    {:ok, _} = Nadia.send_message(message["chat_id"], message["text"])
    {:noreply, 0}
  end

  defp setup_queue(channel) do
    {:ok, _} = Queue.declare(channel, @queue_error, durable: true)
    {:ok, _} = Queue.declare(channel, @queue, durable: true,
                              arguments: [
                                {"x-dead-letter-exchange", :longstr, ""},
                                {"x-dead-letter-routing-key", :longstr, @queue_error}
                                ])
    :ok = Exchange.fanout(channel, @exchange, durable: true)
    :ok = Queue.bind(channel, @queue, @exchange)
  end

end
