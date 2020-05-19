defmodule XQLite3.Result do
  @type t :: %__MODULE__{
          columns: [String.t()] | nil,
          rows: [[term]] | nil
        }

  defstruct [:columns, :rows, :num_rows, :last_insert_id]
end
