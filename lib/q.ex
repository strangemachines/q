defmodule Q do
  @moduledoc """
  Documentation for `Q`.
  """
  @fragment_separator Application.get_env(:q, :fragment_separator, ":")

  def options(), do: {@fragment_separator}

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
