defmodule Fey.EnumR do
  @moduledoc """
  Functions similar to those in `Fey.Enum`, but returning result tuples (`{:ok, value}` or `{:error, :not_found}`)
  instead of option types.
  """

  @doc """
  Returns the element at the specified `index` in the `enum`.

  If the index is out of bounds, returns `{:error, :not_found}`.

  ## Examples

      iex> Fey.EnumR.at([1, 2, 3], 0)
      {:ok, 1}

      iex> Fey.EnumR.at([1, 2, 3], 5)
      {:error, :not_found}
  """
  @spec at(Enumerable.t(), integer()) :: Fey.Result.t(any())
  def at(enum, index) do
    ref = make_ref()

    case Enum.at(enum, index, ref) do
      ^ref -> {:error, :not_found}
      value -> {:ok, value}
    end
  end

  @doc """
  Returns the first element in `enum` for which `fun` returns a truthy value.

  If no such element is found, returns `{:error, :not_found}`.

  ## Examples

      iex> Fey.EnumR.find([1, 2, 3], fn x -> x > 2 end)
      {:ok, 3}

      iex> Fey.EnumR.find([1, 2, 3], fn x -> x > 5 end)
      {:error, :not_found}
  """
  @spec find(Enumerable.t(), (any() -> as_boolean(term()))) :: Fey.Result.t(any())
  def find(enum, fun) do
    ref = make_ref()

    case Enum.find(enum, ref, fun) do
      ^ref -> {:error, :not_found}
      value -> {:ok, value}
    end
  end
end
