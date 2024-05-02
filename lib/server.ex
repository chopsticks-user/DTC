defmodule Server do
  require Logger

  def start() do
    case :gen_tcp.listen(0, [:binary, packet: :line, active: false, reuseaddr: true]) do
      {:ok, socket} ->
        port =
          case :inet.port(socket) do
            {:ok, port} -> port
            {:error, _} -> "unknown"
          end

        Logger.info("Server started succesfully. IP addresses:")

        case get_ip_addrs() do
          {:ok, ip_addrs} ->
            IO.inspect(ip_addrs)

          {:error, reason} ->
            Logger.warn("Failed to obtain IP addresses: (#{reason})")
        end

        Logger.info("Accepting connections at port #{port}")
        accept(socket)

      {:error, reason} ->
        reason_str =
          case reason do
            :eacces -> "Permission denied (:eacces)"
            _ -> reason
          end

        Logger.error("Failed to start server: #{reason_str}")
    end
  end

  defp get_ip_addrs() do
    case :inet.getifaddrs() do
      {:ok, ifaddrs} ->
        ifaddrs =
          ifaddrs
          |> Enum.filter(fn ifaddr -> ifaddr |> elem(1) |> List.keymember?(:addr, 0) end)

        {:ok, [] |> get_addrs_from_ifopt_list(ifaddrs)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp get_addrs_from_ifopt_list(addrs, ifopt_list) do
    case ifopt_list |> List.pop_at(0) do
      {nil, []} ->
        addrs

      {value, new_ifopt_list} ->
        addrs =
          addrs ++
            (value
             |> elem(1)
             |> Enum.filter(fn pair ->
               case pair do
                 {:addr, _} -> true
                 _ -> false
               end
             end))

        get_addrs_from_ifopt_list(addrs, new_ifopt_list)
    end
  end

  defp accept(socket) do
    case :gen_tcp.accept(socket) do
      {:ok, client} ->
        serve(client)
        accept(socket)

      {:error, reason} ->
        reason_str =
          case reason do
            :closed ->
              "ListenSocket is closed (:closed)"

            :timeout ->
              "No connection is established within the specified time (:timeout)"

            :system_limit ->
              "All available ports in the Erlang emulator are in use (:system_limit)"
          end

        Logger.error("Failed to accept the connection request: #{reason_str}")
        :gen_tcp.close(socket)
    end
  end

  defp serve(socket) do
    socket
    |> read_line()
    |> write_line(socket)

    serve(socket)
  end

  defp read_line(socket) do
    {:ok, data} = :gen_tcp.recv(socket, 0)
    data
  end

  defp write_line(line, socket) do
    :gen_tcp.send(socket, line)
  end
end
