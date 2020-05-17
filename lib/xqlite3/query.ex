defmodule XQLite3.Query do
  defstruct [
    :name,
    :statement,
    :ref,
    :column_names,
    :column_types
  ]

  alias XQLite3.Result
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
        ndatetime = %NaiveDateTime{} -> NaiveDateTime.to_string(ndatetime)
        other -> other
      end)
    end

    def decode(
          %Query{column_names: columns, column_types: types, statement: statement},
          %{rows: rows, num_updated_rows: num_updated_rows},
          _opts
        ) do
      rows =
        Enum.map(rows, fn row ->
          row
          |> Enum.zip(types)
          |> Enum.map(&decode_col(&1))
        end)

      num_rows = if is_update?(statement), do: num_updated_rows, else: length(rows)
      rows = if is_update?(statement), do: nil, else: rows
      %Result{rows: rows, num_rows: num_rows, columns: columns}
    end

    def decode_col({:undefined, _}), do: nil
    def decode_col({{:blob, blob}, _}), do: blob
    def decode_col({val, type}) when type in ["bool", "boolean"], do: val == 1
    def decode_col({val, type}) when type in ["time"], do: Time.from_iso8601!(val)
    def decode_col({val, type}) when type in ["date"], do: Date.from_iso8601!(val)

    @doc """
    For e.g., CURRENT_TIMESTAMP SQLite returns the UTC datetime but with
    no timezone specified. Here we make a best-effort of translating datetime columns
    by first trying to parse it as a DateTime, and otherwise falling back to
    parsing it as Naive and translating that to DateTime with the UTC zone.

    Unfortunately, this means that any naive datetimes stored in the database will not be
    returned as such. The application developer is responsible for shifting things as needed.
    """
    def decode_col({val, type}) when type in ["datetime"] do
      case DateTime.from_iso8601(val) do
        {:ok, dt, _} ->
          dt

        {:error, _} ->
          NaiveDateTime.from_iso8601!(val)
          |> DateTime.from_naive!("Etc/UTC")
      end
    end

    def decode_col({val, _type}), do: val

    def is_update?(statement) do
      String.match?(to_string(statement), ~r/(insert|update|delete)\s/i)
    end
  end

  defimpl String.Chars do
    def to_string(%XQLite3.Query{statement: statement}) do
      IO.iodata_to_binary(statement)
    end
  end
end
