defmodule KVServer do
  require Logger

  def accept(port) do
    case port
         |> :gen_tcp.listen([:binary, packet: :line, active: false, reuseaddr: true]) do
      {:ok, socket} ->
        Logger.info(
          "Accepting connections at #{NetUtil.get_ipv4("wlo1") |> Tuple.to_list() |> Enum.join(".")}/#{port}"
        )

        loop_acceptor(socket)

      {:error, reason} ->
        reason_str =
          case reason do
            :eacces -> "Permission denied (:eacces)"
            _ -> reason
          end

        Logger.info("Failed to listen on port #{port}: #{reason_str}")
    end
  end

  defp loop_acceptor(socket) do
    case :gen_tcp.accept(socket) do
      {:ok, client} ->
        serve(client)
        loop_acceptor(socket)

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

        Logger.info("Failed to accept the connection request: #{reason_str}")
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

# KVServer.accept(4040)
