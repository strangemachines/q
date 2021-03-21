defmodule Q.SearchTest do
  use ExUnit.Case
  alias Q.Search

  test "break_shard/1" do
    assert Search.break_shard("x:0") == ["x", "0"]
  end

  test "break_string/1" do
    assert Search.break_string("q:hello") == %{"q" => "hello"}
  end

  test "break_string/1 with more elements" do
    result = Search.break_string("q:hello w:world")
    assert result == %{"q" => "hello", "w" => "world"}
  end

  test "catch_param/2 on c" do
    assert Search.catch_param(%{}, {"c", "u"}) == %{color: "u"}
  end

  test "catch_param/2 on t" do
    assert Search.catch_param(%{}, {"t", "land"}) == %{type: "land"}
  end

  test "catch_param/2 on t with an operator" do
    result = Search.catch_param(%{}, {"t", "-land"})
    assert result == %{type: %{value: "land", operator: "-"}}
  end

  test "catch_param/2 on cmc" do
    assert Search.catch_param(%{}, {"cmc", "3"}) == %{}
  end

  test "catch_param/2 on cmc with an operator" do
    result = Search.catch_param(%{}, {"cmc", ">3"})
    assert result == %{"cmc" => %{operator: ">", value: "3"}}
  end

  test "catch_param/2 on cmc with multiple values" do
    result = Search.catch_param(%{}, {"cmc", ">3,<5"})
    value = [%{operator: "<", value: "5"}, %{operator: ">", value: "3"}]
    assert result == %{"cmc" => value}
  end

  test "catch_param/2 with no matching params" do
    assert Search.catch_param(%{}, %{"x" => "whatever"}) == %{}
  end

  test "parse/1" do
    result = Search.parse(%{"q" => "t:sorcery cmc:>1"})
    parsed = %{"cmc" => %{operator: ">", value: "1"}, :type => "sorcery"}
    assert result == {:ok, parsed}
  end

  test "parse/1 without q" do
    assert Search.parse(:whatever) == %{}
  end
end
