defmodule Fey.KeywordR do
  @doc """
  Alternative to `Keyword.get/2` (and `Fey.Keyword.get/2`), but returns an option instead of value-or-nil. It allows
  to distinguish whether the key was not found at all or it was there, but the value was `nil`.

  NOTE: As the exception when passed argument is not a keyword leaks implementation details,
  it's likely to change in the future. This might not be considered a breaking change.

  ## Examples

      iex> Fey.Keyword.get([a: 1, b: nil], :a)
      {:some, 1}

      iex> Fey.Keyword.get([a: 1, b: nil], :b)
      {:some, nil}

      iex> Fey.Keyword.get([a: 1, b: nil], :c)
      :none

      iex> Fey.Keyword.get(%{a: 1}, :a)
      ** (FunctionClauseError) no function clause matching in Keyword.has_key?/2
  """
  @spec get(Keyword.t(), term()) :: Fey.Option.t(term())
  def get(list, key) do
    if Keyword.has_key?(list, key),
      do: {:some, Keyword.get(list, key)},
      else: :none
  end
end
