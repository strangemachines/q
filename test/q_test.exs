defmodule QTest do
  use ExUnit.Case
  import Dummy
  doctest Q

  test "options/0" do
    assert Q.options() == {":"}
  end

  test "cut_operator/2" do
    assert Q.cut_operator(">operator", ">") == "operator"
  end

  test "put_value/5" do
    dummy Q, [{"cut_operator/2", :value}] do
      result = Q.put_value(">", %{}, "key", ">value", nil)
      assert called(Q.cut_operator(">value", ">"))
      assert result == %{"key" => %{value: :value, operator: ">"}}
    end
  end

  test "put_value/5 with :acc" do
    assert Q.put_value(nil, %{}, :key, :value, :acc) == %{}
  end

  test "put_value/5 with :put" do
    assert Q.put_value(nil, %{}, :key, :value, :put) == %{:key => :value}
  end

  test "match_operators/5" do
    dummy Q, [{"put_value/5", :put_value}] do
      result = Q.match_operators(:key, ">value", %{}, [">"], :mode)
      assert called(Q.put_value(">", %{}, :key, ">value", :mode))
      assert result == :put_value
    end
  end

  test "match_operators/5 with none found" do
    dummy Q, [{"put_value/5", :put_value}] do
      Q.match_operators(:key, "value", %{}, [">"], :mode)
      assert called(Q.put_value(nil, %{}, :key, "value", :mode))
    end
  end

  test "break_string/1" do
    assert Q.break_string("q:hello") == %{"q" => "hello"}
  end

  test "break_string/1 with more elements" do
    result = Q.break_string("q:hello w:world")
    assert result == %{"q" => "hello", "w" => "world"}
  end
end
