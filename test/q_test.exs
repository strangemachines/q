defmodule QTest do
  use ExUnit.Case
  doctest Q

  test "options/0" do
    assert Q.options() == {":"}
  end

  test "cut_operator/2" do
    assert Q.cut_operator(">operator", ">") == "operator"
  end

  test "break_string/1" do
    assert Q.break_string("q:hello") == %{"q" => "hello"}
  end

  test "break_string/1 with more elements" do
    result = Q.break_string("q:hello w:world")
    assert result == %{"q" => "hello", "w" => "world"}
  end
end
