defmodule Q do
  @moduledoc """
  Documentation for `Q`.
  """
  @fragment_separator Application.get_env(:q, :fragment_separator, ":")

  def options(), do: {@fragment_separator}

  @doc """
  Cuts the operator from the value.
  """
  @spec cut_operator(value :: String.t(), operator :: String.t()) :: String.t()
  def cut_operator(value, operator) do
    String.slice(value, String.length(operator)..-1)
  end

  @doc """
  Accumulates a value into a key.
  """
  def accumulate(acc, key, value) do
    if acc[key] != nil do
      Map.update!(acc, key, fn v -> List.flatten([value | [v]]) end)
    else
      Map.put(acc, key, value)
    end
  end

  def put_value(nil, acc, _key, _value, :acc), do: acc

  def put_value(nil, acc, key, value, :put), do: Map.put(acc, key, value)

  @doc """
  Puts the value in the accumulator, creating a value+operator map.
  When there's no operator, the value can be put directly passing :put, or the
  ignored with :acc, which returns the accumulator as is.
  """
  @spec put_value(
          operator :: nil | String.t(),
          acc :: map(),
          key :: String.t(),
          value :: String.t(),
          mode :: :acc | :put
        ) :: map()
  def put_value(op, acc, key, value, _mode) do
    parsed_value = %{value: Q.cut_operator(value, op), operator: op}

    if acc[key] != nil do
      Map.update!(acc, key, fn v -> List.flatten([parsed_value | [v]]) end)
    else
      Map.put(acc, key, %{value: Q.cut_operator(value, op), operator: op})
    end
  end

  @spec match_operators(
          key :: String.t(),
          value :: String.t(),
          acc :: map,
          operators :: [String.t()],
          default_mode :: :acc | :put
        ) :: map()
  def match_operators(key, string, acc, operators, default) do
    string
    |> String.split(",")
    |> Enum.reduce(acc, fn value, accumulator ->
      operators
      |> Enum.find(fn operator -> String.starts_with?(value, operator) end)
      |> Q.put_value(accumulator, key, value, default)
    end)
  end

  @doc """
  Iterates shards against a given function, usually catch_param.
  """
  @spec parse_shards(shards :: map, f :: fun()) :: map()
  def parse_shards(shards, f) do
    Enum.reduce(shards, %{}, fn shard, acc -> f.(acc, shard) end)
  end

  @doc """
  Creates a catch_param function to catch the param when it matches one of
  the operators, or fallback to a default.
  """
  defmacro param(param, key, operators, mode) do
    quote do
      @spec catch_param(acc :: map(), shard :: tuple()) :: map()
      def catch_param(acc, {unquote(param), value}) do
        match_operators(
          unquote(key),
          value,
          acc,
          unquote(operators),
          unquote(mode)
        )
      end
    end
  end

  defmacro param(param, key) do
    quote do
      @spec catch_param(acc :: map(), shard :: tuple()) :: map()
      def catch_param(acc, {unquote(param), value}) do
        put_value(nil, acc, unquote(key), value, :put)
      end
    end
  end

  defmacro __using__(opts \\ []) do
    quote do
      import Q, except: unquote(Keyword.get(opts, :except, []))

      @before_compile Q

      @doc """
      Performs further processing after the parsing has been done.
      """
      @spec post_process(result :: map()) :: map()
      def post_process(result), do: result

      @doc """
      Breaks shards in fragments using the fragments separator, for example
      "x:0" into ["x", "0"]. Can be overriden for custom behaviours.
      """
      @spec break_shard(shard :: String.t()) :: list
      def break_shard(shard), do: String.split(shard, ":")

      @doc """
      Breaks the string in shards and then puts the shards into an
      accumulator. For example, "x:0 y:1" would become %{"x" => 0, "y" => 1}
      """
      @spec break_string(string :: String.t()) :: map()
      def break_string(string) do
        string
        |> String.split()
        |> Enum.reduce(%{}, fn shard, acc ->
          fragments = break_shard(shard)
          Map.put(acc, List.first(fragments), List.last(fragments))
        end)
      end

      def parse(%{"q" => q} = params) do
        q
        |> break_string()
        |> parse_shards(&catch_param/2)
        |> post_process()
      end

      def parse(_params), do: %{}

      defoverridable break_shard: 1, parse: 1, post_process: 1
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def catch_param(acc, _params), do: acc
    end
  end
end
