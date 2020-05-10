defmodule SQLite3Test do
  use ExUnit.Case, async: true
  import SQLite3.TestHelper

  setup do
    {:ok, conn} = SQLite3.start_link(":memory:")
    {:ok, [conn: conn]}
  end

  test "decode basic types", context do
    # todo - should return nil!
    assert [[:undefined]] = query("SELECT NULL;", [])
  end
end
