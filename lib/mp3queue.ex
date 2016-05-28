defmodule Mix.Tasks.Mp3Queue do
  @moduledoc """
  """

  alias Mix.Tasks.Scs.Songlist

  def start_link do
    Agent.start_link(fn -> MapSet.new end, name: __MODULE__)
  end

  @doc "Marks a task as executed"
  def queue_entry(file) do
    item = {file, parse_mp3_file(file)}
    Agent.update(__MODULE__, &MapSet.put(&1, item))
  end

  @doc "Resets the executed tasks and returns the previous list of tasks"
  def take_all(fun) do
    Agent.get(__MODULE__, fn set ->
      MapSet.to_list(set)
      |> Enum.each(fn rec ->
        execute_pair(rec,fun) 
      end)
    end,:infinity)
  end

  def parse_mp3_file(_song) do
    { :call, fn s -> Mp3File.extract_id3(s) end }
  end

  def inspect_song entry do
    # NOOP
    entry
  end

  # Helpers

  defp execute_pair {file, {:call, func}},fun do
    try do
      tags = func.(file)
      fun.(file, tags)
    rescue 
      UnicodeConversionError -> { :error, "UTF-8 Error in #{file}'s MP3 tags" }
      File.Error -> { :error, "FILE #{file} ERROR" }
      e -> { :error,  inspect(e) }
    end
  end


end
