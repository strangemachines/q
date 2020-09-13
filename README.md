# Q

Q is a query parser builder. It allows advanced users to build complex queries in a single input field. Q was inspired by Scryfall.com search input.

For example `e:ia t:-land is:rare` can be parsed to:

```elixir
%{"set" => "ia", "type" => %{value: "land", operator: "-"}, "is" => "rare"}
```

Structured data can then be pattern-matched to build the actual query, for example in an Ecto schema:

```elixir
def filter_set(query, %{"set" => set}), do: where(query, [c], c.set == ^set)

def filter_set(query, _params), do: query
```


## Usage

Use `param` to declare what you want parsed:

```elixir
defmodule MyApp.Search
  use Q

  param("t", :type, ["-"], :put)
end
```

Then call `parse/1` to parse:

```elixir
defmodule MyApp do
  def run() do
    MyApp.Search.parse(%{"q" => "world x:whatever t:magic hello"})
  end
end
```

The above will produce `%{type: "magic"}` Map.
