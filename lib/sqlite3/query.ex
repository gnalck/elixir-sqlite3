defmodule SQLite3.Query do
  defstruct [
    :statement,
    :ref,
    :column_names,
    :column_types
  ]

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

    def decode(_query, params, _opts) do
      params
    end
  end
end
