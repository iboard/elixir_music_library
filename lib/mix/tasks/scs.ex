defmodule Mix.Tasks.Scs do
  @moduledoc """
  Search all mp3 files, recursively in the given path.
  `-p path/to/files` or `--path path/to/files`

  It traverses all files, read their mp3-tags
  and adds an entry to the Songlist-agent.
  """

  use Mix.Task

  defp help do
    IO.puts """
    Options:
       h: :help,  ............... print this screen
       l: :list_all,............. List entire repository
       p: :path, ................ path to files MANDATORY
       i: :list_interpreters, ... output interpreter list
       o: :list_orphands,........ output orphaned entries
       a: :list_albums .......... output album list
     """
  end

  # Mix Task

  @doc "SCS: List mp3 files from path given by -p PATH"
  def run(args) do

    # read and parse options
    { opts, _, _ } = OptionParser.parse(args,
                       aliases: [
                         h: :help,
                         l: :list_all,
                         p: :path,
                         i: :list_interpreters,
                         o: :list_orphands,
                         a: :list_albums
                       ]
                     )

    # Show help and exit if -h is present
    if( opts[:help] ) do
      help
      exit 0
    end
    

    # Initialize and start the library process
    MusicLibrary.start(MusicLibrary,opts)

    # Create a stream of the files to be executed/interpreted, the queue
    # The queue holds a list of files and functions to be executed on it's entries
    queue = MusicLibrary.queue
    IO.write "#{Enum.count(queue)} files to execute."
    

    MusicLibrary.load  # Now, do the hard work (erl will use all cores)
    IO.puts " done."


    # do the output
    if( opts[:list_all], do: MusicLibrary.list_all IO )
    if( opts[:list_interpreters], do: MusicLibrary.list_interpreters IO )
    if( opts[:list_albums], do: MusicLibrary.list_albums IO )
    if( opts[:list_orphands], do: MusicLibrary.list_orphands IO )


  end



end
