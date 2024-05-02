defmodule DTC do
  def main(_) do
    # argv |> parse() |> List.keyfind!(:port, 0) |> elem(1) |> KVServer.accept()
    Server.start()
  end

  # def parse(argv) do
  #   argv
  #   |> OptionParser.parse!(strict: [ipaddr: :string, port: :integer])
  #   |> elem(0)
  # end
end
