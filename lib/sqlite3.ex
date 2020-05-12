defmodule SQLite3 do
  alias SQLite3.Query

  @doc """
  Start the connection process and connect to the database.

  ## Options

    * ':timeout` - configure the default statement timeout in ms.
      Default is provided by `esqlite3` and is currently 5000 ms.

  ## Examples

    iex> {:ok, pid} = SQLite3.start_link(":memory:")
    {:ok #PID<0.71.0>}
  """
  def start_link(path, opts \\ []) do
    opts = [path: path] ++ opts
    DBConnection.start_link(SQLite3.Protocol, opts)
  end

  @doc """
  Returns a supervisor child specification for a DBConnection pool.
  """
  def child_spec(opts) do
    DBConnection.child_spec(SQLite3.Protocol, opts)
  end

  @doc """
  Runs a query and returns the result as `{:ok, %SQLite3.Result{}}` or
  `{:error, %SQLite3.Error{}}` if there was a database error. Parameters
  can be set in the query as `$1` embeddded in the query string. Parameters
  are given as a list of Elixir values.
  """
  def query(conn, statement, params, opts \\ []) do
    case DBConnection.prepare_execute(conn, %Query{statement: statement}, params, opts) do
      {:ok, _, result} -> {:ok, result}
      {:error, _} = error -> error
    end
  end

  @doc """
  Runs a query and returns the result or raises `SQLite3.Error` if there
  was an error. See `query/3`.
  """
  def query!(conn, statement, params, opts \\ []) do
    case query(conn, statement, params, opts) do
      {:ok, result} -> result
      {:error, err} -> raise err
    end
  end
end
