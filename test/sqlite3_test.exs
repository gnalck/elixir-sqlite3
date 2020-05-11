defmodule SQLite3Test do
  use ExUnit.Case, async: true
  import SQLite3.TestHelper

  setup do
    {:ok, conn} = SQLite3.start_link(":memory:")
    {:ok, [conn: conn]}
  end

  # sqlite has dynamic typing, and so if there is no backing type
  # we pretty much use the 'raw' return value - as we cannot
  # intelligently convert them.
  test "decode basic types without backing table", context do
    assert [[nil]] = query("SELECT NULL", [])
    assert [[1]] = query("SELECT 1", [])
    assert [["1"]] = query("SELECT '1'", [])
    assert [[1, 0]] = query("SELECT true, false", [])
    assert [["e"]] = query("SELECT 'e'", [])
    assert [["ẽ"]] = query("SELECT 'ẽ'", [])
    assert [[42]] = query("SELECT 42", [])
    assert [[42.0]] = query("SELECT 42.0", [])
    assert [[<<16, 0>>]] = query("SELECT x'1000'", [])

    # cause seg fault - likely issue with esqlite
    # assert [["Inf"]] = query("SELECT 9e999", [])
    # assert [["-Inf"]] = query("SELECT -9e999", [])
  end

  test "column names", context do
    assert {:ok, res} = SQLite3.query(context[:conn], "select 1 as A, 2 as B", [])
    assert %SQLite3.Result{} = res
    assert ["a", "b"] == res.columns
  end

  test "encode and decode bool / boolean", context do
    assert [] = query("CREATE TABLE foo(a BOOL, b BOOLEAN)", [])
    assert [] = query("INSERT INTO foo VALUES($1, $2)", [true, false])
    assert [[true, false]] == query("SELECT * FROM foo", [])
  end

  test "encode and decode time", context do
    time = ~T[23:51:02.491415]
    assert [] = query("CREATE TABLE foo(a TIME)", [])
    assert [] = query("INSERT INTO foo VALUES($1)", [time])
    assert [[time]] == query("SELECT * FROM foo", [])
  end

  test "encode and decode date", context do
    date = ~D[2020-05-11]
    assert [] = query("CREATE TABLE foo(a DATE)", [])
    assert [] = query("INSERT INTO foo VALUES($1)", [date])
    assert [[date]] == query("SELECT * FROM foo", [])
  end

  test "encode and decode datetime", context do
    datetime = ~U[2020-05-11 00:28:33.696598Z]
    assert [] = query("CREATE TABLE foo(a DATETIME)", [])
    assert [] = query("INSERT INTO foo VALUES($1)", [datetime])
    assert [[datetime]] == query("SELECT * FROM foo", [])
  end

  test "encode and decode blob", context do
    blob = <<16, 0>>
    assert [] = query("CREATE TABLE foo(a BLOB)", [])
    assert [] = query("INSERT INTO foo VALUES($1)", [blob])
    assert [[blob]] = query("SELECT * from foo", [])
  end

  test "insert", context do
    assert [] == query("CREATE TABLE foo(bar);", [])
    assert [] == query("SELECT * from foo", [])
    assert [] == query("INSERT INTO foo VALUES ($1)", ["wow"])
    assert [["wow"]] == query("SELECT * FROM foo", [])
  end

  test "decode basic types with backing table", context do
    assert [] = query("CREATE TABLE TEST(int INT, text TEXT, real REAL, blob BLOB);", [])
  end
end
