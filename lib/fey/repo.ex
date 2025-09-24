defmodule Fey.Repo do
  @moduledoc """
  This module provides extensions for Ecto repositories
  """

  defmacro __using__(_opts) do
    quote do
      def get_opt(schema, id) do
        __ENV__.module.get(schema, id)
        |> Fey.Option.wrap_not_nil()
      end
    end
  end
end
