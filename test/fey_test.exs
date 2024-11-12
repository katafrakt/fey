defmodule FeyTest do
  use ExUnit.Case
  doctest Fey

  test "greets the world" do
    assert Fey.hello() == :world
  end
end
