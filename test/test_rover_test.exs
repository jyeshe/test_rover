defmodule TestRoverTest do
  use ExUnit.Case
  doctest TestRover

  test "greets the world" do
    assert TestRover.hello() == :world
  end
end
