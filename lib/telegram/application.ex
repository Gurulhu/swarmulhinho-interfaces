defmodule Telegram.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do

    children = [
      # Starts a worker by calling: TesteApp.Worker.start_link(arg)
      # {TesteApp.Worker, arg}
      {Telegram.Producer, []},
      {Telegram.Consumer, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Telegram.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
