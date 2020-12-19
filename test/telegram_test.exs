defmodule TelegramTest do
  use ExUnit.Case
  doctest Telegram

  test "greets the world" do
    assert Telegram.hello() == :world
  end
end
