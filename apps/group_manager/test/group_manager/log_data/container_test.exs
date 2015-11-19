defmodule GroupManager.LogData.ContainerTest do
  use ExUnit.Case
  
  defstruct dummy: nil

  alias GroupManager.LogData.Container, as: Container
  alias GroupManager.LogData.LogEntry, as: LogEntry
  alias GroupManager.LogData.ContainerTest, as: ContainerTest

  test "cannot add empty LogEntry to the container" do
    c = %Container{}
    l = %LogEntry{}
    
    assert {:error, :missing_parent} == Container.add(c, l)
  end
  
  test "cannot add incompatible type to the container" do
    c = %Container{}
    i = %ContainerTest{}
    
    assert_raise MatchError, fn ->
      Container.add(c, i)
    end
  end

  test "cannot use other type as container" do
    c = %ContainerTest{}
    l = %LogEntry{}
    
    assert_raise MatchError, fn ->
      Container.add(c, l)
    end
  end
  
  test "can initialize container once" do
    c = %Container{}
    assert {:ok, _} = Container.init(c)
  end

  test "cannot initialize container twice" do
    c = %Container{}
    assert {:ok, new_c} = Container.init(c)
    assert {:error, _} = Container.init(new_c)
  end

end