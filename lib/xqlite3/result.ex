defmodule XQLite3.Result do
  @type t :: %__MODULE__{
          columns: [String.t()] | nil,
          rows: [[term]] | nil
        }

  defstruct [:columns, :rows]
end
