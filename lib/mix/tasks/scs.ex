defmodule Mix.Tasks.Scs do
  @moduledoc """
  """

  use Mix.Task

  def start_link do
    Agent.start_link(fn -> MapSet.new end, name: __MODULE__)
  end

  @doc "Marks a task as executed"
  def put_entry(song, tags) do
    item = {song, tags}
    Agent.update(__MODULE__, &MapSet.put(&1, item))
  end


  @shortdoc "SCS: List directory as ID3 List"
  def run(args) do
    start_link
    { opts, _, _ } = OptionParser.parse(args,
                       aliases: [
                         p: :path
                       ]
                     )


    list = Mp3File.list(opts[:path])
     
    song_map = Stream.map( list, fn song ->
      case parse_mp3_file(song) do
        { :ok, %{album: "", artist: "", title: ""} } -> { 0, song, :empty }
        { :ok, tags }         -> { 1, song, tags }
        { :error, message }   -> { 0, :error, message }
      end
    end)
    |> Stream.filter( fn {count,_,_} -> count > 0 end) 
    |> Stream.map(fn {count, song, entry} -> inspect_song(count,song,entry) end)

    song_map 
      |> Enum.reduce( 0, fn _entry,acc -> acc+1 end)
      |> IO.puts

    song_map
      |> Enum.each(fn {_count, song, entry} -> put_entry(song,entry) end)

    inspect(take_all) |> IO.puts 
  end

  @doc "Resets the executed tasks and returns the previous list of tasks"
  def take_all() do
    Agent.get(__MODULE__, fn set ->
      MapSet.to_list(set)
      |> Enum.each(fn rec ->
        execute_pair(rec) 
      end)
    end,60000)
  end

  defp execute_pair rec do
    IO.puts inspect(rec)
    { file, func } = rec
    IO.puts "FILE: #{file}"
    IO.puts "FUNC: #{inspect func}"
    try do
      tags = func.(file)
      IO.puts "TAGS: #{inspect tags}"
    rescue
      UnicodeConversionError -> { :error, "UTF-8 Error in #{file}'s MP3 tags" }
      File.Error -> { :error, "FILE #{file} ERROR" }
    end
  end
  defp inspect_song count,song,entry do
    IO.puts "#{song} => #{inspect(entry)}"
    {count,song,entry}
  end

  defp parse_mp3_file(song) do
    try do
      { :ok, fn s -> Mp3File.extract_id3(s) end }
    rescue
      UnicodeConversionError -> { :error, "UTF-8 Error in #{song}'s MP3 tags" }
    end
  end

end
