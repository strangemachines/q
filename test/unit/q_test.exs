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

  test "accumulate/3" do
    assert Q.accumulate(%{}, :key, :one) == %{:key => :one}
  end

  test "accumulate/3 with an existing key" do
    assert Q.accumulate(%{:key => :one}, :key, :two) == %{:key => [:two, :one]}
  end

  test "put_value/5" do
    dummy Q, [{"cut_operator/2", :value}, {"accumulate/3", :accumulate}] do
      result = Q.put_value(">", %{}, "key", ">value", nil)
      assert called(Q.cut_operator(">value", ">"))
      assert called(Q.accumulate(%{}, "key", %{value: :value, operator: ">"}))
      assert result == :accumulate
    end
  end

  test "put_value/5 with :acc" do
    assert Q.put_value(nil, %{}, :key, :value, :acc) == %{}
  end

  test "put_value/5 with :put" do
    dummy Q, [{"accumulate/3", :accumulate}] do
      assert Q.put_value(nil, %{}, :key, :value, :put) == :accumulate
      assert called(Q.accumulate(%{}, :key, :value))
    end
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

  test "parse_shards/2" do
    result = Q.parse_shards(%{"k" => "v"}, fn _acc, x -> x end)
    assert result == {"k", "v"}
  end
end
