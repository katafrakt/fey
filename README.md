# Fey

Fey is a set of functions to work with result tuples and their counterparts - option values. It is heavily inspired by OCaml naming conventions and built for people who like their pipe operator (perhaps too much).

``` elixir
Repo.get(DataFile, id)
|> Fey.Result.wrap_not_nil()
|> Fey.Result.map(fn df -> df.filename end)
|> Fey.Result.bind(fn fname -> File.open(fname) end)
|> Fey.Result.bind(fn contents -> Jason.decode(contents) end)
|> Fey.Map.get("score")
|> Fey.Result.get_with_default(0.0)
```

This code reads the records from the database, wraps it in the result tuple and then, only when the record was found, performs a bunch of operations on it.

This is a classic railway-oriented programming, which could just as well be modelled using the Elixir-native `with` clause. However some people don't like using `with` and in this case it might be not so nice, as not all the steps return proper result tuple. For example, its beginning would have to be:

``` elixir
with record when not is_nil(record) <- Repo.get(DataFile, id),
```

Fey offers a different approach: use a regular function that returns data-or-nil and then call `Fey.Result.wrap_not_nil/1` on it, which results in either `{:ok, record}` or `{:error, :not_found}`. Then it's taken through a pipeline of functions operating on the results ~~monad~~[^1] tuple.

### Option vs Result

Fey encourages using option ~~monad~~ instead of result where it makes sense. Result is best when we are talking about a result of an operation, however option works better when we lookup something.

And option, similar to result, is either a `{:some, value}` tuple or `:none` atom. We can see it in action:

``` elixir
[1, 2, 3]
|> Fey.Enum.find(& rem(&1, 2) == 0)
#=> {:some, 2}

[1, 2, 3]
|> Fey.Enum.find(& &1 > 5
#=> :none
```

## Installation

The package can be installed by adding `fey` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:fey, "~> 0.0.1"}
  ]
end
```

## Footnotes

[^1]: Ooops, I said the M-word...
