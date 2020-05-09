defmodule SQLite3.Protocol do
  @moduledoc """
  Implements DBConnection behavior for SQLite
  """

  alias SQLite3.Query

  @behaviour DBConnection

  # todo: mode?
  defstruct db: nil,
            status: :idle

  @impl DBConnection
  def connect(opts) do
    path = Keyword.fetch!(opts, :path)
    path = if is_binary(path), do: String.to_charlist(path), else: path

    case Sqlitex.open(path, opts) do
      {:ok, db} ->
        {:ok, %__MODULE__{db: db}}

      err ->
        err
    end
  end

  @impl DBConnection
  def disconnect(_reason, state) do
    Sqlitex.close(state.db)
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
  def handle_prepare(%Query{query: query}, _opts, %{db: db} = s) do
    case Sqlitex.Statement.prepare(db, query) do
      {:ok, statement} -> {:ok, %Query{query: query, statement: statement}, s}
      err -> {:error, conn_error(err), s}
    end
  end

  @impl DBConnection
  def handle_execute(%Query{statement: stmt} = query, params, _opts, s) do
    with {:ok, stmt} <- Sqlitex.Statement.bind_values(stmt, []),
         {:ok, res} <- Sqlitex.Statement.fetch_all(stmt) do
      {:ok, query, res, s}
    else
      {:error, err} -> {:error, conn_error(err), s}
    end
  end

  # prepared statements are deallocated for us via NIF's destruct_esqlite_statement
  @impl DBConnection
  def handle_close(_, _, s), do: {:ok, nil, %{s | stmt: nil}}

  @impl DBConnection
  def handle_declare(_query, _params, _opts, state) do
    {:error, SQLite3.Error.exception("cursor not yet supported"), state}
  end

  @impl DBConnection
  def handle_fetch(_query, _cursor, _opts, state) do
    {:error, SQLite3.Error.exception("cursor not yet supported"), state}
  end

  # prepared statements are deallocated for us via NIF's destruct_esqlite_statement
  @impl DBConnection
  def handle_deallocate(_query, _cursor, _opts, s), do: {:ok, nil, %{s | stmt: nil}}

  defp conn_error({:sqlite_error, msg}), do: conn_error(msg)

  defp conn_error(msg) do
    DBConnection.ConnectionError.exception(msg)
  end

  defp handle_transaction(%{db: db} = s, sql, new_status) do
    case Sqlitex.exec(db, sql) do
      :ok ->
        {:ok, nil, %{s | status: new_status}}

      {:error, err} ->
        {:disconnect, conn_error(err), s}
    end
  end
end
