defmodule NetUtil do
  def get_ipv4(net_intf_name) when is_list(net_intf_name) do
    {:ok, addrs} = :inet.getifaddrs()

    matched_ipv4_pairs =
      Enum.filter(elem(List.keyfind(addrs, net_intf_name, 0), 1), fn item ->
        case item do
          {:addr, value} when tuple_size(value) == 4 -> true
          _ -> false
        end
      end)

    ipv4_pair = List.first(matched_ipv4_pairs)

    case ipv4_pair do
      nil -> nil
      _ -> elem(ipv4_pair, 1)
    end
  end

  def get_ipv4(net_intf_name) when is_binary(net_intf_name) do
    get_ipv4(to_charlist(net_intf_name))
  end

  def get_ipv4(_) do
    nil
  end
end
