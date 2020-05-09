defmodule SQLite3Test do
  use ExUnit.Case, async: true
  import SQLite3.TestHelper
  import SQLite3

  setup context do
    {:ok, conn} = SQLite3.start_link(":memory:")
    {:ok, [conn: conn]}
  end

  test "decode basic types", context do
    assert [[nil]] = query("SELECT NULL;", [])
  end
end
