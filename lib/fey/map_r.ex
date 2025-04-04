defmodule Fey.MapR do
  @doc """
  Alternative to `map[key]` (and `Fey.Map.get`), but returns a result tuple instead of value-or-nil.
  It allows to distinguish whether the key was not found at all or it was there, but the value was `nil`.
  If the key wasn't in the map, returns `{:error, :not_found}`.

  If you prefer option, see `Fey.Map.get/2`.

  ## Examples

      iex> Fey.MapR.get(%{a: 1, b: nil}, :a)
      {:ok, 1}

      iex> Fey.MapR.get(%{a: 1, b: nil}, :b)
      {:ok, nil}

      iex> Fey.MapR.get(%{a: 1, b: nil}, :c)
      {:error, :not_found}

      iex> Fey.MapR.get([1,2,3], :x)
      ** (BadMapError) expected a map, got: [1, 2, 3]
  """
  @spec get(map(), any()) :: Fey.Result.t(term())
  def get(map, key) do
    if Map.has_key?(map, key),
      do: {:ok, map[key]},
      else: {:error, :not_found}
  end
end
