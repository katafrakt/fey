ExUnit.start()
{:ok, _pid} = Fey.TestRepo.start_link()

# the database is in-memory, so whe can safely migrate it manually every time
Ecto.Adapters.SQL.query!(Fey.TestRepo, """
CREATE TABLE things (
  id INTEGER PRIMARY KEY,
  name TEXT
)
""")

Ecto.Adapters.SQL.Sandbox.mode(Fey.TestRepo, :manual)
