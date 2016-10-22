defmodule Mp3Proxy do
  @moduledoc """
  Holds a %Mp3Repo struct with a set of functions to be executed for
  each entry. The 'execute' function of this module then executes the function when
  needed.
  """
  alias Songlist
  alias Mp3Repo

  @doc "Start with an empty set in path :path from args"
  def start_link args do
    path = args[:path] 
    Agent.start_link(fn -> %Mp3Repo{path: path} end, name: __MODULE__)
  end

  @doc "add entry to the set"
  def add_entry(filename) do
    item = {filename, parse_mp3_file(filename)}
    Agent.update(__MODULE__, fn(current_state) ->
      %Mp3Repo{
        path: current_state.path, 
        set: MapSet.put(current_state.set, item)
      }
    end)
  end

  @doc "Traverse the set of enties and execute the given functions"
  def each(fun) do
    Agent.get(__MODULE__, fn state ->
      MapSet.to_list(state.set)
      |> Enum.each(fn rec -> load_and_yield(rec,fun) end)
    end,:infinity)
  end

  @doc "define the function to be called when executed while traversing in `each`"
  def parse_mp3_file(_song) do
    { :call, fn s -> Mp3File.extract_id3(s) end }
  end

  @doc "Extract the list of files from the current state"
  def all do
    Agent.get(__MODULE__, fn state -> Mp3File.all(state.path) end)
  end

  # Helpers

  defp load_and_yield {file, {:call, query_func}}, yield do
    try do
      tags = query_func.(file) # EXPENSIVE!
      yield.(file, tags)
      IO.write(".")
    rescue 
      UnicodeConversionError -> { :error, "UTF-8 Error in #{file}'s MP3 tags" }
      File.Error -> { :error, "FILE #{file} ERROR" }
      error -> { :error,  inspect(error) }
    end
  end


end
