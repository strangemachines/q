# Q

Q is a query parser builder. It allows advanced users to build complex queries in a single input field. Q was inspired by Scryfall.com search input.

For example `e:ia t:-land c:u` can be parsed to:

```elixir
%{"set" => "ia", "type" => %{value: "land", operator: "-"}, "color" => "u"}
```

Structured data can then be pattern-matched to build the actual query, for example in an Ecto schema:

```elixir
def filter_set(query, %{"set" => set}), do: where(query, [c], c.set == ^set)

def filter_set(query, _params), do: query
```

## Installation


Add the dependency to your mix.exs:

```elixir
{:q_parser, "~> 1.2"}
```


## Usage

Use `param` to declare what you want parsed:

```elixir
defmodule MyApp.Search
  use Q
  param("c", :color)

  param("t", :type, ["-"], :put)

  param("cmc", "cmc", [">", "<"], :acc)
end
```

Then call `parse/1` to parse:

```elixir
defmodule MyApp do
  def run() do
    MyApp.Search.parse(%{"q" => "hello x:whatever t:magic c:u cmc:>2,<5"})
  end
end
```

The above will produce:

```elixir
%{
  color => "u",
  type => "magic",  
  "cmc" => [%{operator: "<", value: "5"}, %{operator: ">", value: "2"}]
}
```
