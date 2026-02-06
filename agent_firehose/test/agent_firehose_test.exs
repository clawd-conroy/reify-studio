defmodule AgentFirehoseTest do
  use ExUnit.Case
  doctest AgentFirehose

  test "greets the world" do
    assert AgentFirehose.hello() == :world
  end
end
