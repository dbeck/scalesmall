defmodule GroupManager.RangeEvent.SplitTest do
  use ExUnit.Case

  test "can merge the same values into one" do
    a = %GroupManager.RangeEvent.Split{point: 0.5}
    b = a
    assert [a] == GroupManager.RangeEvent.Split.merge([a,b])
  end
  
  test "can merge distinct values" do
    a = %GroupManager.RangeEvent.Split{point: 0.5}
    b = %GroupManager.RangeEvent.Split{point: 0.6}
    c = [a, b]
    assert c == GroupManager.RangeEvent.Split.merge([a,b])
  end
end