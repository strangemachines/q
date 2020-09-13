defmodule Q.SearchTest do
  use ExUnit.Case
  alias Q.Search

  test "catch_param/2 on t" do
    assert Search.catch_param(%{}, %{"t" => "land"}) == %{"type" => "land"}
  end

  test "catch_param/2 on t with an operator" do
    result = Search.catch_param(%{}, %{"t" => "-land"})
    assert result == %{"type" => %{value: "land", operator: "-"}}
  end

  test "catch_param/2 on cmc" do
    assert Search.catch_param(%{}, %{"cmc" => "3"}) == %{}
  end

  test "catch_param/2 on cmc with an operator" do
    result = Search.catch_param(%{}, %{"cmc" => ">3"})
    assert result == %{"cmc" => %{operator: ">", value: "3"}}
  end

  test "catch_param/2 with no matching params" do
    assert Search.catch_param(%{}, %{"x" => "whatever"}) == %{}
  end
end
