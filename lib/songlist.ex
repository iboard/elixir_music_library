
defmodule Mix.Tasks.Scs.Songlist do
  def start_link do
    Agent.start_link(fn -> MapSet.new end, name: __MODULE__)
  end

  def put_entry(song, tags) do
    id = :crypto.hash(:sha256, song) |> Base.encode16
    item = {id, Map.put(tags,:file, song)}
    Agent.update(__MODULE__, &MapSet.put(&1, item))
  end

  def list_all do
    Agent.get(__MODULE__, fn set ->
      MapSet.to_list(set)
      |> Enum.each( fn {id,tags} ->
        IO.puts id <> "=>" <> inspect(tags)
      end)
    end)
  end
end
