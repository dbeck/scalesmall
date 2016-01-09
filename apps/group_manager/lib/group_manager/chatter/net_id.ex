defmodule GroupManager.Chatter.NetID do

  require Record

  Record.defrecord :net_id, ip: nil, port: 0
  @type t :: record( :net_id, ip: tuple, port: integer )

  defmacro is_valid_port(data) do
    case Macro.Env.in_guard?(__CALLER__) do
      true ->
        quote do
          is_integer(unquote(data)) and
          unquote(data) >= 0 and
          unquote(data) <= 0xffff
        end
      false ->
        quote bind_quoted: [result: data] do
          is_integer(data) and
          data >= 0 and
          data <= 0xffff
        end
    end
  end

  defmacro is_valid_ip(ip) do
    case Macro.Env.in_guard?(__CALLER__) do
      true ->
        quote do
          is_tuple(unquote(ip)) and
          tuple_size(unquote(ip)) == 4 and
          is_integer(:erlang.element(1,unquote(ip))) and
          is_integer(:erlang.element(2,unquote(ip))) and
          is_integer(:erlang.element(3,unquote(ip))) and
          is_integer(:erlang.element(4,unquote(ip))) and
          :erlang.element(1,unquote(ip)) >= 0 and
          :erlang.element(2,unquote(ip)) >= 0 and
          :erlang.element(3,unquote(ip)) >= 0 and
          :erlang.element(4,unquote(ip)) >= 0 and
          :erlang.element(1,unquote(ip)) < 256 and
          :erlang.element(2,unquote(ip)) < 256 and
          :erlang.element(3,unquote(ip)) < 256 and
          :erlang.element(4,unquote(ip)) < 256
        end
      false ->
        quote bind_quoted: [result: ip] do
          is_tuple(ip) and
          tuple_size(ip) == 4 and
          is_integer(:erlang.element(1,ip)) and
          is_integer(:erlang.element(2,ip)) and
          is_integer(:erlang.element(3,ip)) and
          is_integer(:erlang.element(4,ip)) and
          :erlang.element(1,ip) >= 0 and
          :erlang.element(2,ip) >= 0 and
          :erlang.element(3,ip) >= 0 and
          :erlang.element(4,ip) >= 0 and
          :erlang.element(1,ip) < 256 and
          :erlang.element(2,ip) < 256 and
          :erlang.element(3,ip) < 256 and
          :erlang.element(4,ip) < 256
        end
    end
  end

  @spec new(tuple, integer) :: t
  def new(ip, port)
  # TODO : IPV6
  when is_valid_ip(ip) and is_valid_port(port)
  do
    net_id(ip: ip) |> net_id(port: port)
  end

  defmacro is_valid(data) do
    case Macro.Env.in_guard?(__CALLER__) do
      true ->
        quote do
          is_tuple(unquote(data)) and tuple_size(unquote(data)) == 3 and
          :erlang.element(1, unquote(data)) == :net_id and
          # ip
          # TODO : IPV6
          is_tuple(:erlang.element(2, unquote(data))) and
          tuple_size(:erlang.element(2, unquote(data))) == 4 and
          # port
          is_integer(:erlang.element(3, unquote(data))) and
          :erlang.element(3, unquote(data)) >= 0 and
          :erlang.element(3, unquote(data)) <= 0xffff
        end
      false ->
        quote bind_quoted: [result: data] do
          is_tuple(result) and tuple_size(result) == 3 and
          :erlang.element(1, result) == :net_id and
          # ip
          # TODO : IPV6
          is_tuple(:erlang.element(2, data)) and
          tuple_size(:erlang.element(2, data)) == 4 and
          # port
          is_integer(:erlang.element(3, result)) and
          :erlang.element(3, result) >= 0 and
          :erlang.element(3, result) <= 0xffff
        end
    end
  end

  @spec valid?(t) :: boolean
  def valid?(data)
  when is_valid(data)
  do
    true
  end

  def valid?(_), do: false

  @spec validate_list(list(t)) :: :ok | :error
  def validate_list([]), do: :ok

  def validate_list([head|rest])
  do
    case valid?(head) do
      true -> validate_list(rest)
      false -> :error
    end
  end

  @spec validate_list!(list(t)) :: :ok
  def validate_list!([]), do: :ok

  def validate_list!([head|rest])
  when is_valid(head)
  do
    validate_list!(rest)
  end

  @spec ip(t) :: tuple
  def ip(id)
  when is_valid(id)
  do
    net_id(id, :ip)
  end

  @spec port(t) :: integer
  def port(id)
  when is_valid(id)
  do
    net_id(id, :port)
  end
end
