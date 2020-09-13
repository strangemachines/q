defmodule Q.Search do
  @moduledoc """
  This module exists only so that I can test the macros in Q.
  """
  use Q

  param("t", :type, ["-"], :put)

  param("cmc", "cmc", [">", "<"], :acc)
end
