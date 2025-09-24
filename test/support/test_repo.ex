defmodule Fey.TestRepo do
  use Ecto.Repo,
    otp_app: :fey,
    adapter: Ecto.Adapters.SQLite3

  use Fey.Repo

  defmodule Thing do
    use Ecto.Schema

    schema "things" do
      field(:name, :string)
    end
  end
end
