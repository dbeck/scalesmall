defmodule GroupManager.LogData.ContainerTest do
  use ExUnit.Case
  
  defstruct dummy: nil

  alias GroupManager.LogData.Container
  alias GroupManager.LogData.LogEntry
  alias GroupManager.LogData.Data
  alias GroupManager.LogData.ContainerTest

  test "cannot add to uninitialized container" do
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

  test "cannot add first_entry to an initialized container because first entry should already be there" do
    c = %Container{}
    first = Container.first_entry()
    {:ok, newc} = Container.init(c)
    assert {:error, _} = Container.add(newc, first)
  end 
  
  test "can add to initialized container" do
    c = %Container{}
    assert {:ok, c} = Container.init(c)
    
    # create a new entry, linked to the first one
    %LogEntry{data: _, new_hash: first_hash} = Container.first_entry()
    data = %Data{prev_hash: first_hash}
    new_entry = %LogEntry{data: data, new_hash: Data.hash(data)}

    # add the new entry
    assert {:ok, c2, :inserted} = Container.add(c, new_entry)
    
    # add the new entry again
    assert {:ok, c2, :already_exists} == Container.add(c2, new_entry)
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
  
  test "cannot initialize unsupported container type" do
    c = %ContainerTest{}
    assert_raise MatchError, fn ->
      Container.init(c)
    end
  end
  
  test "latest in an empty container is an empty list" do
    c = %Container{}
    assert [] == Container.latest(c)
  end
  
  test "latest in an initialized container is the first entry" do
    c = %Container{}
    {:ok, c} = Container.init(c)
    %LogEntry{data: _, new_hash: first_hash} = Container.first_entry()
    assert [first_hash] == Container.latest(c)
  end

end