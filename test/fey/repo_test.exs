defmodule Fey.Extensions.EctoTest do
  use ExUnit.Case, async: true

  alias Fey.TestRepo
  alias Fey.TestRepo.Thing

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(TestRepo)
  end

  describe "get_opt/1" do
    test "return {:some, _} when record exists" do
      thing =
        %Thing{name: "test"}
        |> TestRepo.insert!()

      assert {:some, th} = TestRepo.get_opt(Thing, thing.id)
      assert th.id == thing.id
    end

    test "return :none when record does not exist" do
      assert TestRepo.get_opt(Thing, 0) == :none
    end
  end
end
