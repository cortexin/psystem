defmodule PsystemTest do
  use ExUnit.Case
  doctest Psystem

  test "greets the world" do
    assert Psystem.hello() == :world
  end
end
