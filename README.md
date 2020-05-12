# sqlite3
This creates a connection pooled sqlite driver by combining `esqlite` and `db_connection`.

Now that the dirty scheduler more widely available, in the long run we hope to later replace `esqlite` with
our own implementation that leverages `ERL_NIF_DIRTY_JOB_IO_BOUND` instead to make the NIF have less custom logic.
