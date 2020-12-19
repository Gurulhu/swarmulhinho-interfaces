defmodule Telegram.Producer do
  use GenServer

  @moduledoc """
  Documentation for `Telegram`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Telegram.hello()
      :world

  """

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @queue        "Telegram"

  def init(:ok) do
    update()
    {:ok, 0}
  end

  def handle_cast(:update, offset) do
    new_offset = Nadia.get_updates([offset: offset, timeout: 1])
      |> process_messages

    {:noreply, new_offset + 1, 100}
  end

  defp process_messages({:ok, []}) do -1 end

  defp process_messages({:ok, results}) do
    results
    |> Enum.map(fn %{message: %{text: text, chat: %{id: chat_id}}, update_id: id} = message ->
      message
      |> send_mq

    id
    end)
    |> List.last
  end

  def handle_info(:timeout, offset) do
    update()
    {:noreply, offset}
  end

  defp send_mq(message) do
    {:ok, connection} = AMQP.Connection.open(Telegram.Config.amqp_server_string)
    {:ok, channel} = AMQP.Channel.open(connection)

    %{message: %{text: text, chat: %{id: chat_id}}} = message
    AMQP.Basic.publish(channel, "", @queue, Jason.encode!(%{text: text, chat_id: chat_id}))
  end

  def update do
    GenServer.cast(__MODULE__, :update)
  end

end
