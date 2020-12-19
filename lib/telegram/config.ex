defmodule Telegram.Config do

  def amqp_server_string, do: config_or_env(:amqp_server_string)


  #Got the idea from https://github.com/zhyu/nadia/blob/master/lib/nadia/config.ex
  defp config_or_env(key) do
    case Application.fetch_env(:telegram, key) do
      {:ok, {:system, var}} ->
        System.get_env(var)

      {:ok, {:system, var, default}} ->
        case System.get_env(var) do
          nil -> default
          val -> val
        end

      {:ok, value} ->
        value

      :error ->
        nil
    end
  end

end
