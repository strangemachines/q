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
    Map.put(acc, key, %{value: Q.cut_operator(value, op), operator: op})
  end

  @doc """
  Breaks the string in fragments and then puts the fragments into an
  accumulator. For example, "x:0 y:1" would become %{"x" => 0, "y" => 1}
  """
  @spec break_string(string :: String.t()) :: map()
  def break_string(string) do
    string
    |> String.split()
    |> Enum.reduce(%{}, fn shard, acc ->
      fragment = String.split(shard, ":")
      Map.put(acc, List.first(fragment), List.last(fragment))
    end)
  end
end
