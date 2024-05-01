defmodule DataTransferCliTest do
  use ExUnit.Case
  doctest DataTransferCli

  test "greets the world" do
    assert DataTransferCli.hello() == :world
  end
end
