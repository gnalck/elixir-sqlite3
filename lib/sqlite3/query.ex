defmodule SQLite3.Query do
  defstruct [:query, :statement]

  defimpl DBConnection.Query do
    def parse(query, _opts) do
      query
    end

    def describe(query, _opts) do
      query
    end

    def encode(_query, params, _opts) do
      params
    end

    def decode(_query, params, _opts) do
      params
    end
  end
end
