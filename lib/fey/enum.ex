defmodule Fey.Enum do
  @moduledoc """
  `Fey.Enum` module provides alternatives to some functions from `Enum` module from the standard
  library, returning option informing about the result of the lookup. This allows, among others,
  to distinguish between situation when the found value is `nil` and when the value is not found.
  """

  @doc """
  Alternative to `Enum.at/2` which returns an option: `{:some, value}` if there is a value
  at given index or `:none` if there isn't such element.

  ## Examples

      iex> Fey.Enum.at([1, nil, 2], 1)
      {:some, nil}

      iex> Fey.Enum.at([1, 2, 3], 5)
      :none

      iex> Fey.Enum.at([1, nil, :none], 2)
      {:some, :none}

      iex> Fey.Enum.at(%{a: 1, b: 2}, 1)
      {:some, {:b, 2}}
  """
  def at(enum, index) do
    ref = make_ref()

    case Enum.at(enum, index, ref) do
      ^ref -> :none
      value -> {:some, value}
    end
  end

  @doc """
  Alternative to `Enum.find` which returns an option: `{:some, value}` if a value matching the
  condition is found or `:none` if no such value was found.

  ## Examples

      iex> Fey.Enum.find([1, 2, 3], &rem(&1, 2) == 0)
      {:some, 2}

      iex> Fey.Enum.find([1, 3, 5], &rem(&1, 2) == 0)
      :none

      iex> Fey.Enum.find(%{a: 1, b: 2}, fn {_, v} -> rem(v, 2) == 0 end)
      {:some, {:b, 2}}
  """
  def find(enum, fun) do
    ref = make_ref()

    case Enum.find(enum, ref, fun) do
      ^ref -> :none
      value -> {:some, value}
    end
  end
end
