defmodule GroupManager.LogData.ContainerTest do
  use ExUnit.Case
  
  defstruct dummy: nil

  alias GroupManager.LogData.Container
  alias GroupManager.LogData.LogEntry
  alias GroupManager.LogData.Data
  alias GroupManager.LogData.ContainerTest
  alias GroupManager.RangeEvent.Split
  alias GroupManager.RangeEvent.Node
  alias GroupManager.RangeEvent.Event

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
    c = Container.init
    
    # create a new entry, linked to the first one
    %LogEntry{data: _, new_hash: first_hash} = Container.first_entry()
    data = %Data{prev_hash: first_hash}
    new_entry = %LogEntry{data: data, new_hash: Data.hash(data)}
    
    # add the new entry
    assert {:ok, c2, :inserted} = Container.add(c, new_entry)
    
    # check the latest list too
    %LogEntry{data: _, new_hash: new_hash} = new_entry
    assert [new_hash] == Container.latest(c2)
    
    # add the new entry again
    assert {:ok, c2, :already_exists} == Container.add(c2, new_entry)
    
    # and another entry linked to the very first one
    split_event = %Split{point: 0.3}
    ev1 = %Event{split: [split_event]}
    data2 = %Data{prev_hash: first_hash, range_event: ev1}
    new_entry2 = %LogEntry{data: data2, new_hash: Data.hash(data2)}
    
    # add the second entry
    assert {:ok, c3, :inserted} = Container.add(c2, new_entry2)
    
    # check the latest list too
    %LogEntry{data: _, new_hash: new_hash2} = new_entry2
    assert [new_hash2, new_hash] == Container.latest(c3)
    
    # add the second entry again
    assert {:ok, c3, :already_exists} == Container.add(c3, new_entry2)
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