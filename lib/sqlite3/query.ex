defmodule SQLite3.Query do
  defstruct [:statement]

  defimpl DBConnection.Query do
    def parse(query, _opts) do
      query
    end

    def describe(query, _opts) do
      query
    end

    def encode(query, _params, _opts) do
      query
    end

    def decode(query, _result, _opts) do
      query
    end
  end
end
