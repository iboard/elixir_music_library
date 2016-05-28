defmodule Mix.Tasks.Scs do
  @moduledoc """
  Search all mp3 files, recursively in the given path.
  `-p path/to/files` or `--path path/to/files`

  It traverses all files, read their mp3-tags
  and adds an entry to the Songlist-agent.
  """

  use Mix.Task

  # Songlist Agent

  alias Mix.Tasks.Mp3Queue      # find and parse mp3
  alias Mix.Tasks.Scs.Songlist  # keep the results 


  # Mix Task

  @shortdoc "SCS: List directory as ID3 List"
  def run(args) do
    Songlist.start_link
    Mp3Queue.start_link

    { opts, _, _ } = OptionParser.parse(args,
                       aliases: [
                         p: :path
                       ]
                     )


    # Get a list of files and (lazy) parse their mp3 tags
    mp3_files = Mp3File.list(opts[:path])
     
    # Create a stream of the files to execute
    queue =  
      mp3_files |> Stream.map(fn mp3 -> Mp3Queue.queue_entry(mp3) end)

    IO.write "#{Enum.count(queue)} files to execute."


    # Now, do the hard work (erl will use all cores)
    IO.write "Parsing MP3-tags "
    Mp3Queue.take_all( fn file,tags ->
      Songlist.put_entry(file,tags)
      IO.write "."
    end)

    IO.puts " done."
    Songlist.list_all
  end



end
