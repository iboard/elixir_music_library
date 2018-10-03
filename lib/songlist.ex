defmodule Songlist do
  def start_link do
    Agent.start_link(fn -> MapSet.new() end, name: __MODULE__)
  end

  def add(song, tags) do
    id = :crypto.hash(:sha256, song) |> Base.encode16()
    item = {id, Map.put(tags, :file, song)}
    Agent.update(__MODULE__, &MapSet.put(&1, item))
  end

  def all do
    Agent.get(__MODULE__, fn set ->
      MapSet.to_list(set)
      |> Enum.map(fn {id, tags} ->
        id <> " => " <> inspect(tags)
      end)
    end)
  end

  def artists, do: list(:artist)
  def albums, do: list(:album)

  def orphaned do
    Agent.get(__MODULE__, fn set ->
      MapSet.to_list(set)
      |> Enum.filter(fn {_id, e} -> e[:artist] == "" end)
      |> Enum.map(fn {id, e} -> "#{id} #{e[:file]}" end)
      |> Enum.sort(fn a, b -> a < b end)
      |> Enum.uniq()
    end)
  end

  defp list(field) do
    Agent.get(__MODULE__, fn set ->
      MapSet.to_list(set)
      |> Enum.filter(fn {_id, e} -> e[field] != "" end)
      |> Enum.map(fn {_id, tags} -> tags[field] end)
      |> Enum.sort(fn a, b -> a < b end)
      |> Enum.uniq()
    end)
  end
end
