defmodule GroupManager.RangeEvent.SplitTest do
  use ExUnit.Case

  alias GroupManager.RangeEvent.Split

  test "can merge the same values into one" do
    a = %Split{point: 0.5}
    b = a
    assert [a] == Split.merge([a,b])
  end
  
  test "can merge distinct values" do
    a = %Split{point: 0.5}
    b = %Split{point: 0.6}
    c = [a, b]
    assert c == Split.merge([a,b])
  end
  
  test "cannot compare invalid / negative values " do
    a = %Split{point: -0.5}
    b = %Split{point: 0.6}
    assert_raise FunctionClauseError, fn ->
      Split.is_greater(a,b)
    end
  end

  test "cannot compare invalid out-of-range values " do
    a = %Split{point: 1.5}
    b = %Split{point: 0.6}
    assert_raise FunctionClauseError, fn ->
      Split.is_greater(a,b)
    end
  end
  
  test "cannot merge invalid / negative values " do
    a = %Split{point: -0.5}
    b = %Split{point: 0.6}
    assert_raise FunctionClauseError, fn ->
      Split.merge([a,b])
    end
  end

  test "cannot merge invalid out-of-range values " do
    a = %Split{point: 1.5}
    b = %Split{point: 0.6}
    assert_raise FunctionClauseError, fn ->
      Split.merge([a,b])
    end
  end  
end