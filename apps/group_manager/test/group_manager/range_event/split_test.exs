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
end