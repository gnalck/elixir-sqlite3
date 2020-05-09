# sqlite3
This creates a connection pooled sqlite driver by combining `esqlite` and `db_connection`.

Now that the dirty scheduler more widely available, in the long run we hope to later replace `esqlite` with
our own implementation that leverages `ERL_NIF_DIRTY_JOB_IO_BOUND` instead to make the NIF have less custom logic.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `sqlite3` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:sqlite3, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/sqlite3](https://hexdocs.pm/sqlite3).

