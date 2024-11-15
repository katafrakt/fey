defmodule Fey.Result do
  @moduledoc """
  The module provides functions to work with a well-established pattern of result tuples
  (sometimes called "tagged tuples") in Elixir. By them we mean `{:ok, value}` or `{:error, error}`
  tuples.

  `Fey.Result` adds a bunch of convenience to work with these, especially in pipelines. They can replace
  `with` chains, which are frowned upon by some people in the Elixir community. Let's see an example:

  ```elixir
  Repo.fetch(OrderLineItem, 123)
  |> Fey.Result.map(& &1.sku)
  |> Fey.Result.bind(&Repo.get_by(Product, sku: &1) |> Fey.Result.wrap_not_nil(:sku_not_found))
  |> Fey.Result.map(& &1.name)
  ```

  This either returns a name of the product for line item (matches by SKU) or any of the intermediate
  errors that might happpen: `{:ok, :not_found}` (from `Repo.fetch`) or `{:error, :sku_not_found}`.
  """

  @type success :: {:ok, term()}
  @type error :: {:error, term()}
  @type t :: success() | error()

  defmodule BadArgument do
    defexception [:message]
  end

  defmodule NotSuccess do
    defexception [:message]
  end

  defmodule NotError do
    defexception [:message]
  end

  @doc """
  Wraps a value in a success result tuple (i.e. `{:ok, value}`).

  Note that it does not check whether a value passed as argument is already a valid
  result tuple, or not.

  ## Examples

      iex> Fey.Result.wrap(true)
      {:ok, true}

      iex> Fey.Result.wrap({:ok, "fourty two"})
      {:ok, {:ok, "fourty two"}}
  """
  @spec wrap(term()) :: success()
  def wrap(value), do: {:ok, value}

  @doc """
  Similar to `wrap/1`, but only returns a success result if the passed value is not `nil`.
  If it is, `{:error, error}` is returned, where `error` is either passed as a second
  argument, or by default is `:not_found`.

  Note that generally `Fey.Option.wrap_not_nil/1` is preferred, as it's more idiomatic.
  However, if you're set on using `Result`, this is available.

  ## Examples

      iex> Fey.Result.wrap_not_nil(42)
      {:ok, 42}

      iex> Fey.Result.wrap_not_nil(nil)
      {:error, :not_found}

      iex> Fey.Result.wrap_not_nil(nil, :number_missing)
      {:error, :number_missing}
  """
  @spec wrap_not_nil(term(), atom()) :: t()
  def wrap_not_nil(value, error \\ :not_found) do
    case value do
      nil -> {:error, error}
      _ -> wrap(value)
    end
  end

  @doc """
  Returns whether or not the passed value is a success.
  Raises Fey.Result.BadArgument if the value is not a valid result tuple.

  ## Examples

      iex> Fey.Result.ok?({:ok, true})
      true

      iex> Fey.Result.ok?({:error, :not_found})
      false

      iex> Fey.Result.ok?(42)
      ** (Fey.Result.BadArgument) 42 is not a valid result tuple
  """
  @spec ok?(t()) :: boolean()
  def ok?(result) do
    case result do
      {:ok, _} -> true
      {:error, _} -> false
      _ -> raise BadArgument, message: "#{inspect(result)} is not a valid result tuple"
    end
  end

  @doc """
  Returns whether or not the passed value is an error.

  Raises Fey.Result.BadArgument if the value is not a valid result tuple.

  ## Examples

      iex> Fey.Result.error?({:ok, true})
      false

      iex> Fey.Result.error?({:error, :not_found})
      true

      iex> Fey.Result.error?(42)
      ** (Fey.Result.BadArgument) 42 is not a valid result tuple
  """
  @spec error?(t()) :: boolean()
  def error?(result), do: not ok?(result)

  @doc """
  If the result is a success, returns its value.

  Raises `Fey.Result.NotSuccess` if the result is not successful.
  Raises `Fey.Result.BadArgument` if the value passed as argument is not a valid result tuple.

  ## Examples

      iex> Fey.Result.get!({:ok, 42})
      42

      iex> Fey.Result.get!({:error, :not_found})
      ** (Fey.Result.NotSuccess) {:error, :not_found} is not a success

      iex> Fey.Result.get!(:some_atom)
      ** (Fey.Result.BadArgument) :some_atom is not a valid result tuple
  """
  @spec get!(t()) :: any()
  def get!(result) do
    case result do
      {:ok, value} -> value
      {:error, _} -> raise NotSuccess, message: "#{inspect(result)} is not a success"
      _ -> raise BadArgument, message: "#{inspect(result)} is not a valid result tuple"
    end
  end

  @doc """
  If the result is a success, return its value but if the result is an error, return default value
  instead of raising exception (like `get!/1` does).

  Raises `Fey.Result.BadArgument` if the value passed as argument is not a valid result tuple.

  ## Examples

      iex> Fey.Result.get_with_default({:ok, 42}, 1567)
      42

      iex> Fey.Result.get_with_default({:error, :not_found}, 1567)
      1567

      iex> Fey.Result.get_with_default("string", 1567)
      ** (Fey.Result.BadArgument) "string" is not a valid result tuple
  """
  def get_with_default(result, default_value) do
    case result do
      {:ok, value} -> value
      {:error, _} -> default_value
      _ -> raise BadArgument, message: "#{inspect(result)} is not a valid result tuple"
    end
  end

  @doc """
  If the result is an error, return its details.

  Raises NotError if the result is not errorneous.

  Raises `Fey.Result.BadArgument` is the value passed as argument is not a valid result tuple.

  ## Examples

      iex> Fey.Result.error!({:error, :not_found})
      :not_found

      iex> Fey.Result.error!({:ok, 42})
      ** (Fey.Result.NotError) {:ok, 42} is not an error

      iex> Fey.Result.error!(:some_atom)
      ** (Fey.Result.BadArgument) :some_atom is not a valid result tuple
  """
  def error!(result) do
    case result do
      {:error, error} -> error
      {:ok, _} -> raise NotError, message: "#{inspect(result)} is not an error"
      _ -> raise BadArgument, message: "#{inspect(result)} is not a valid result tuple"
    end
  end

  @doc """
  If the result is a success, returns `{:ok, val}`, where `val` is a return value of fun applied on result's value.

  If the result is an error, returns error itself.

  Raises `Fey.Result.BadArgument` if the value passed as argument is not a valid result tuple.

  ## Examples

      iex> Fey.Result.map({:ok, 42}, fn v -> v / 2 end)
      {:ok, 21.0}

      iex> Fey.Result.map({:error, :not_found}, fn v -> v / 2 end)
      {:error, :not_found}

      iex> Fey.Result.map(:some_atom, fn v -> v / 2 end)
      ** (Fey.Result.BadArgument) :some_atom is not a valid result tuple
  """
  @spec map(t(), fun) :: t()
  def map(result, fun) do
    case result do
      {:ok, value} -> {:ok, fun.(value)}
      {:error, error} -> {:error, error}
      _ -> raise BadArgument, message: "#{inspect(result)} is not a valid result tuple"
    end
  end

  @doc """
  If the result is a success, returns a value of fun applied on result's value. It's analogous to `map/2`, but does not wrap
  in `{:ok, val}` automatically, which makes it useful if fun returns a result.

  If the result is an error, returns error itself.

  Raises `Fey.Result.BadArgument` if the value passed as argument is not a valid result tuple.

  ## Examples

      iex> Fey.Result.bind({:ok, 42}, fn v -> {:ok, v / 2} end)
      {:ok, 21.0}

      iex> Fey.Result.bind({:ok, 42}, fn v -> v / 2 end)
      21.0

      iex> Fey.Result.bind({:error, :not_found}, fn v -> {:ok, v / 2} end)
      {:error, :not_found}

      iex> Fey.Result.bind(:some_atom, fn v -> {:ok, v / 2} end)
      ** (Fey.Result.BadArgument) :some_atom is not a valid result tuple
  """
  @spec bind(t(), fun) :: any()
  def bind(result, fun) do
    case result do
      {:ok, value} -> fun.(value)
      {:error, error} -> {:error, error}
      _ -> raise BadArgument, message: "#{inspect(result)} is not a valid result tuple"
    end
  end

  @doc """
  Inverse of `bind/2` - if the result is an error, executes fun and returns its result.

  If the result is success, just returns it.

  Raises `Fey.Result.BadArgument` if the value passed as argument is not a valid result tuple.

  This function makes most sense when used in a pipeline where you want to
  take the first successful result. For example:

  ```elixir
  parse_as_iso_datetime(input)
  |> Fey.Result.bind_error(fn -> parse_as_iso_date(input) end)
  |> Fey.Result.bind_error(fn -> parse_as_naive_datetime(input) end)
  |> Fey.Result.bind_error(fn -> parse_as_naive_date(input) end)

  # {:ok, parsed_date} | {:error, :bad_format}
  ```

  ## Examples

      iex> Fey.Result.bind_error({:error, :not_found}, fn -> {:ok, 42} end)
      {:ok, 42}

      iex> Fey.Result.bind_error({:ok, nil}, fn -> {:ok, 42} end)
      {:ok, nil}

      iex> Fey.Result.bind_error(nil, fn -> {:ok, 42} end)
      ** (Fey.Result.BadArgument) nil is not a valid result tuple
  """
  @spec bind_error(t(), fun) :: any()
  def bind_error(result, fun) do
    case result do
      {:ok, value} -> {:ok, value}
      {:error, _error} -> fun.()
      _ -> raise BadArgument, message: "#{inspect(result)} is not a valid result tuple"
    end
  end
end
