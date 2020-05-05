defmodule Sqlite3Test do
  use ExUnit.Case
  doctest Sqlite3

  test "greets the world" do
    assert Sqlite3.hello() == :world
  end
end
