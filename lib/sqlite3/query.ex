defmodule SQLite3.Query do
  defstruct [
    :statement,
    :ref,
    :column_names,
    :column_types
  ]

  alias SQLite3.Result
  alias __MODULE__, as: Query

  defimpl DBConnection.Query do
    def parse(query, _opts) do
      query
    end

    def describe(query, _opts) do
      query
    end

    @spec encode(any, [any], Keyword.t()) :: any
    def encode(_query, params, _opts) do
      Enum.map(params, fn
        nil -> :undefined
        true -> 1
        false -> 0
        date = %Date{} -> Date.to_string(date)
        time = %Time{} -> Time.to_string(time)
        datetime = %DateTime{} -> DateTime.to_string(datetime)
        other -> other
      end)
    end

    def decode(%Query{column_names: columns, column_types: types}, rows, _opts) do
      rows =
        Enum.map(rows, fn row ->
          row
          |> Enum.zip(types)
          |> Enum.map(&decode_col(&1))
        end)

      %Result{rows: rows, columns: columns}
    end

    def decode_col({:undefined, _}), do: nil
    def decode_col({val, type}), do: val
  end
end
