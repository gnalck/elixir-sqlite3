defmodule XQLite3.Protocol do
  @moduledoc """
  Implements DBConnection behavior for SQLite
  """
  alias XQLite3.Query

  @behaviour DBConnection

  # todo: mode?
  defstruct db: nil,
            status: :idle

  @impl DBConnection
  @spec connect(opts :: Keyword.t()) :: {:ok, state :: any} | {:error, Exception.t()}
  def connect(opts) do
    path = Keyword.fetch!(opts, :path)
    path = if is_binary(path), do: String.to_charlist(path), else: path

    # todo: timeout, too
    case :esqlite3.open(path) do
      {:ok, db} ->
        {:ok, %__MODULE__{db: db}}

      err ->
        err
    end
  end

  @impl DBConnection
  @spec disconnect(err :: Exception.t(), state :: any) :: :ok
  def disconnect(_reason, %{db: db}) do
    :esqlite3.close(db)
  end

  # as far as I know checkout/checkin is used for
  # making sure state is in the correct, well, state
  # before passing control of it to another process
  # since we merely have a file handle, effectively
  # there is not much we need to do, so its a no-op.
  @impl DBConnection
  def checkout(state), do: {:ok, state}

  @impl DBConnection
  def checkin(state), do: {:ok, state}

  # no point in pinging a file!
  @impl DBConnection
  def ping(state), do: {:ok, state}

  # todo: handle case where we begin but are in transaction
  # todo: allow different modes (transaction v savepoint)
  @impl DBConnection
  def handle_begin(_opts, s), do: handle_transaction(s, "BEGIN", :transaction)

  # todo: right now we just get error from sqlite if e.g., not in transaction
  # we could do some better guarding here instead
  @impl DBConnection
  def handle_commit(_opts, s), do: handle_transaction(s, "COMMIT", :idle)

  @impl DBConnection
  def handle_rollback(_opts, s), do: handle_transaction(s, "ROLLBACK", :idle)

  @impl DBConnection
  def handle_status(_, %{status: status} = s), do: {status, s}

  @impl DBConnection
  def handle_prepare(%Query{statement: statement} = q, _opts, %{db: db} = s) do
    with {:ok, ref} <- :esqlite3.prepare(statement, db),
         column_names <- get_column_names(ref),
         column_types <- get_column_types(ref) do
      {:ok, %{q | ref: ref, column_names: column_names, column_types: column_types}, s}
    else
      err -> {:error, conn_error(err), s}
    end
  end

  @impl DBConnection
  def handle_execute(%Query{ref: ref} = q, params, _opts, %{db: db} = s) do
    with :ok <- :esqlite3.bind(ref, params),
         res <- :esqlite3.fetchall(ref),
         {:ok, num_updated_rows} <- :esqlite3.changes(db),
         rows <- Enum.map(res, &Tuple.to_list(&1)) do
      {:ok, q, %{rows: rows, num_updated_rows: num_updated_rows}, s}
    else
      {:error, err} -> {:error, conn_error(err), s}
    end
  end

  # prepared statements are deallocated for us via NIF's destruct_esqlite_statement
  @impl DBConnection
  def handle_close(_, _, s), do: {:ok, nil, s}

  @impl DBConnection
  def handle_declare(_query, _params, _opts, state) do
    {:error, XQLite3.Error.exception("cursor not yet supported"), state}
  end

  @impl DBConnection
  def handle_fetch(_query, _cursor, _opts, state) do
    {:error, XQLite3.Error.exception("cursor not yet supported"), state}
  end

  # prepared statements are deallocated for us via NIF's destruct_esqlite_statement
  @impl DBConnection
  def handle_deallocate(_query, _cursor, _opts, s), do: {:ok, nil, s}

  defp conn_error({:error, err}), do: conn_error(err)
  defp conn_error({:sqlite_error, msg}), do: conn_error(msg)
  defp conn_error(msg) when is_list(msg), do: conn_error(to_string(msg))
  defp conn_error(msg) when is_atom(msg), do: conn_error(Atom.to_string(msg))
  defp conn_error(msg), do: DBConnection.ConnectionError.exception(msg)

  defp handle_transaction(%{db: db} = s, sql, new_status) do
    case :esqlite3.exec(sql, db) do
      :ok ->
        {:ok, nil, %{s | status: new_status}}

      {:error, err} ->
        {:disconnect, conn_error(err), s}
    end
  end

  @spec get_column_types(any()) :: list()
  defp get_column_types(ref) do
    :esqlite3.column_types(ref)
    |> Tuple.to_list()
    |> atoms_lower()
  end

  @spec get_column_names(any()) :: list()
  defp get_column_names(ref) do
    :esqlite3.column_names(ref)
    |> Tuple.to_list()
    |> atoms_lower()
  end

  @spec atoms_lower([atom()]) :: [String.t()]
  defp atoms_lower(atoms) do
    Enum.map(atoms, fn a -> Atom.to_string(a) |> String.downcase() end)
  end
end
