defmodule SQLite3 do
  def start_link(path, opts \\ []) do
    opts = [path: path] ++ opts
    DBConnection.start_link(SQLite3.Protocol, opts)
  end

  def child_spec(opts) do
    DBConnection.child_spec(SQLite3.Protocol, opts)
  end

  def query(conn, query, params, opts \\ []) do
    case DBConnection.prepare_execute(conn, query, params, opts) do
      {:ok, _, result} -> {:ok, result}
      {:error, _} = error -> error
    end
  end

  # def query(conn, statement, params, opts \\ []) do
  #   case DBConnection.prepare_execute(conn, query, params, opts) do
  #     {:ok, _, result} -> {:ok, result}
  #     {:error, _} error -> error
  #   end
  # end
end
