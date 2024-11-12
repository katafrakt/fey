defmodule Fey.Option do
  @moduledoc """
  `Option` module serves a similar, but less popular in Elixir, pattern. Instead of `{:ok, something}`
  or `{:error, message}` tuples, `Option` works with `{:some, value}` or `:none`.

  Unlike `Result`, which is best used to describe the results of some operation, that might have
  finished successfully or error out, `Option` is more geared towards working with optional
  data.

  It might be a good replacement of `nil`. Let's say that we have a function returning nth
  element of some list:

  ```elixir
  def nth(list, idx), do: Enum.at(list, idx)
  ```

  This works well, but you have no way to distinguish whether the index you asked for was
  out of bounds or simply the value at this point was `nil`. This could be solved by using
  `Option`:

  ```elixir
  def nth([head | _], 0), do: {:some, head}
  def nth([], _), do: :none
  def nth[head | tail], idx), do: nth(tail, idx - 1)

  iex> nth([1, nil, 3], 1)
  {:some, nil}

  iex> nth([1, nil, 3], 4)
  :none
  ```

  This is obviously a very simplified example, but it shows why the difference might matter.
  In "real" applications it's often the difference between "not yet fetched/calculated" and
  "fetched/calculated, but has no value".
  """

  @type some :: {:some, term()}
  # none is a built-in type and we cannot redefine it
  @type none_ :: :none
  @type t :: some() | none_()

  defmodule BadArgument do
    defexception [:message]
  end

  defmodule NotSome do
    defexception [:message]
  end

  defmodule NotNone do
    defexception [:message]
  end

  @doc """
  Wraps a value in option tuple (i.e. `{:some, value}`)

  ## Examples

      iex> Fey.Option.wrap(true)
      {:some, true}

      iex> Fey.Option.wrap(nil)
      {:some, nil}

      iex> Fey.Option.wrap({:some, 15})
      {:some, {:some, 15}}
  """
  @spec wrap(term()) :: some()
  def wrap(value), do: {:some, value}

  @doc """
  Similar to `wrap/1`, but only returns a some-tuple if the passed value is not `nil`.
  Otherwise `:none` is returned.

  Note that generally it's preferred over `Fey.Result.wrap_not_nil/2`.

  ## Examples

      iex> Fey.Option.wrap_not_nil(42)
      {:some, 42}

      iex> Fey.Option.wrap_not_nil(nil)
      :none
  """
  @spec wrap_not_nil(term()) :: t()
  def wrap_not_nil(value) do
    case value do
      nil -> :none
      val -> {:some, val}
    end
  end

  @doc """
  Returns whether or not the passed value is some.
  Raises `Fey.Option.BadArgument` if the value is not a valid option.

  ## Examples

      iex> Fey.Option.some?({:some, 42})
      true

      iex> Fey.Option.some?(:none)
      false

      iex> Fey.Option.some?(nil)
      ** (Fey.Option.BadArgument) nil is not a valid option
  """
  @spec some?(t()) :: boolean()
  def some?(option) do
    case option do
      {:some, _} -> true
      :none -> false
      _ -> raise BadArgument, message: "#{inspect(option)} is not a valid option"
    end
  end

  @doc """
  Returns whether or not the passed values is none.
  Raises `Fey.Option.BadArgument` if the values is not a valid option

  ## Examples

      iex> Fey.Option.none?(:none)
      true

      iex> Fey.Option.none?({:some, 42})
      false

      iex> Fey.Option.none?(nil)
      ** (Fey.Option.BadArgument) nil is not a valid option
  """
  @spec none?(t()) :: boolean()
  def none?(option), do: not some?(option)

  @doc """
  If the option is some, returns its value.

  Raises `Fey.Option.NotSome` if the result is not some.
  Raises `Fey.Option.BadArgument` if the value is not a valid option tuple.

  ## Examples

      iex> Fey.Option.get!({:some, 42})
      42

      iex> Fey.Option.get!(:none)
      ** (Fey.Option.NotSome) :none is not some

      iex> Fey.Option.get!(nil)
      ** (Fey.Option.BadArgument) nil is not a valid option
  """
  @spec get!(t()) :: any()
  def get!(option) do
    case option do
      {:some, value} -> value
      :none -> raise NotSome, message: "#{inspect(option)} is not some"
      _ -> raise BadArgument, message: "#{inspect(option)} is not a valid option"
    end
  end

  @doc """
  If the option is some, return its value, but if the option is non, return a default value
  instead of raising exception (like `get!/1` does).

  Raises `Fet.Option.BadArgument` if the values passed as argument is not a valid option.

  ## Examples

      iex> Fey.Option.get_with_default({:some, 42}, 10)
      42

      iex> Fey.Option.get_with_default(:none, 10)
      10

      iex> Fey.Option.get_with_default("string", 10)
      ** (Fey.Option.BadArgument) "string" is not a valid option
  """
  @spec get_with_default(t(), any()) :: any()
  def get_with_default(option, default) do
    case option do
      {:some, value} -> value
      :none -> default
      _ -> raise BadArgument, message: "#{inspect(option)} is not a valid option"
    end
  end

  @doc """
  If the option is some, returns `{:some, val}`, where `val` is a return value of fun applied on option's value.

  If the option is none, returns `:none`.

  Raises `Fey.Option.BadArgument` if the value passed as argument is not a valid option.

  ## Examples

      iex> Fey.Option.map({:some, 42}, fn v -> v * 2 end)
      {:some, 84}

      iex> Fey.Option.map(:none, fn v -> v * 2 end)
      :none

      iex> Fey.Option.map(55, fn v -> v * 2 end)
      ** (Fey.Option.BadArgument) 55 is not a valid option
  """
  @spec map(t(), fun) :: t()
  def map(option, fun) do
    case option do
      {:some, value} -> {:some, fun.(value)}
      :none -> :none
      _ -> raise BadArgument, message: "#{inspect(option)} is not a valid option"
    end
  end

  @doc """
  If the option is some, returns a value of fun applied on option's value. It's analogous to `map/2`, but
  does not wrap in `{:some, val}` automatically, which makes it useful if `fun` returns an option.

  If the option is none, returns none.

  Raises `Fey.Option.BadArgument` if the value passed as argument is not a valid option.

  ## Examples

      iex> Fey.Option.bind({:some, 42}, fn v -> {:some, v/2} end)
      {:some, 21.0}

      iex> Fey.Option.bind({:some, 42}, fn v -> v/2 end)
      21.0

      iex> Fey.Option.bind(:none, fn v -> {:some, v/2} end)
      :none

      iex> Fey.Option.bind(15, fn v -> {:some, v/2} end)
      ** (Fey.Option.BadArgument) 15 is not a valid option
  """
  @spec bind(t(), fun) :: any()
  def bind(option, fun) do
    case option do
      {:some, value} -> fun.(value)
      :none -> :none
      _ -> raise BadArgument, message: "#{inspect(option)} is not a valid option"
    end
  end
end
