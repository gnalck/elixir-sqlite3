defmodule XQLite3 do
  @moduledoc """
  SQLite3 driver for Elixir.
  """

  alias XQLite3.{Query, Result, Error}

  @doc """
  Start the connection process and connect to the database.

  ## Options

    * `:path` - the path to the database. If no database exists at that
      path, one will be created there. For in-memory database, provide `:memory:`
    * `:timeout` - configure the default statement timeout in ms.
      Default is provided by `esqlite3` and is currently 5000 ms.

  ## Examples

    iex> {:ok, pid} = XQLite3.start_link(":memory:")
    {:ok #PID<0.71.0>}
  """
  def start_link(path, opts \\ []) do
    opts = [path: path] ++ opts
    DBConnection.start_link(XQLite3.Protocol, opts)
  end

  @doc """
  Returns a supervisor child specification for a DBConnection pool.
  """
  def child_spec(opts) do
    DBConnection.child_spec(XQLite3.Protocol, opts)
  end

  @doc """
  Runs a query and returns the result as `{:ok, %XQLite3.Result{}}` or
  `{:error, %XQLite3.Error{}}` if there was a database error. Parameters
  can be set in the query as `$1` embeddded in the query string. Parameters
  are given as a list of Elixir values.
  """
  def query(conn, statement, params, opts \\ []) do
    case DBConnection.prepare_execute(conn, %Query{statement: statement}, params, opts) do
      {:ok, _, result} -> {:ok, result}
      {:error, _} = error -> error
    end
  end

  @spec prepare_execute(any, iodata, iodata, list, [any]) ::
          {:ok, Query.t(), Result.t()} | {:error, Error.t()}
  def prepare_execute(conn, name, statement, params, opts \\ []) do
    query = %Query{name: name, statement: statement}
    DBConnection.prepare_execute(conn, query, params, opts)
  end

  @doc """
  Runs a query and returns the result or raises `XQLite3.Error` if there
  was an error. See `query/3`.
  """
  def query!(conn, statement, params, opts \\ []) do
    case query(conn, statement, params, opts) do
      {:ok, result} -> result
      {:error, err} -> raise err
    end
  end

  @spec execute(any, Query.t(), list, [any]) ::
          {:ok, Query.t(), Result.t()} | {:error, Error.t()}
  def execute(conn, query, params, opts \\ []) do
    DBConnection.execute(conn, query, params, opts)
  end
end
