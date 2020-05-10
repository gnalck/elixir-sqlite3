ExUnit.start()

defmodule SQLite3.TestHelper do
  defmacro query(stat, params, opts \\ []) do
    quote do
      case SQLite3.query(var!(context)[:conn], unquote(stat), unquote(params), unquote(opts)) do
        {:ok, rows} -> rows
        {:error, err} -> err
      end
    end
  end
end
