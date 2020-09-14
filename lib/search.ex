defmodule Q.Search do
  @moduledoc """
  This module exists only so that I can test the macros in Q.
  """
  use Q

  param("c", :color)

  param("t", :type, ["-"], :put)

  param("cmc", "cmc", [">", "<"], :acc)

  def post_process(result) do
    {:ok, result}
  end
end
