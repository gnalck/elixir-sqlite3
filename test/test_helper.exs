ExUnit.start()

defmodule XQLite3.TestHelper do
  defmacro query(stat, params, opts \\ []) do
    quote do
      case XQLite3.query(var!(context)[:conn], unquote(stat), unquote(params), unquote(opts)) do
        {:ok, %XQLite3.Result{rows: rows}} -> rows
        {:error, err} -> err
      end
    end
  end
end
