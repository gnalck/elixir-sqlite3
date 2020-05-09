ExUnit.start()

defmodule SQLite3.TestHelper do
  defmacro query(stat, params, opts \\ []) do
    quote do
      case SQLite3.query(var!(context)[:conn], unquote(stat), unquote(params), unquote(opts)) do
        {:ok, %SQLite3.Result{rows: nil}} -> :ok
        {:ok, %SQLite3.Result{rows: rows}} -> rows
        {:error, err} -> err
      end
    end
  end
end
