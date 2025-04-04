defmodule Fey.Map do
  @doc """
  Alternative to `map[key]`, but returns an option instead of value-or-nil. It allows
  to distinguish whether the key was not found at all or it was there, but the value was `nil`.

  If you prefer results over options, see `Fey.MapR.get/2`.

  ## Examples

      iex> Fey.Map.get(%{a: 1, b: nil}, :a)
      {:some, 1}

      iex> Fey.Map.get(%{a: 1, b: nil}, :b)
      {:some, nil}

      iex> Fey.Map.get(%{a: 1, b: nil}, :c)
      :none

      iex> Fey.Map.get([1,2,3], :x)
      ** (BadMapError) expected a map, got: [1, 2, 3]
  """
  @spec get(map(), any()) :: Fey.Option.t(term())
  def get(map, key) do
    if Map.has_key?(map, key),
      do: {:some, map[key]},
      else: :none
  end
end
