defmodule MusicLibrary do
  use Application
  alias Mp3Proxy
  alias Songlist

  def start(_type, args) do
    import Supervisor.Spec, warn: false

    children = [
      worker( Songlist, [] ),
      worker( Mp3Proxy, [args] )
    ]

    opts = [strategy: :one_for_one, name: MusicLibrary.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def queue do
    all_files 
    |> Stream.map(fn mp3 -> Mp3Proxy.add_entry(mp3) end)
  end

  def load do
    Mp3Proxy.each( fn file,mp3_tags ->
      Songlist.add(file,mp3_tags)
    end)
  end

  # OUTPUT FUNCTIONS

  def list_all io do
    io.puts "\n\nSONGLIST - all"
    Songlist.all 
    |> Enum.join("\n") 
    |> io.puts
  end

  def list_interpreters io do
    io.puts "\n\nSONGLIST - artists"
    Songlist.artists 
    |> Enum.join("\n") 
    |> io.puts
  end

  def list_albums io do
    io.puts "\n\nSONGLIST - albums"
    Songlist.albums 
    |> Enum.join("\n") 
    |> io.puts
  end

  def list_orphands io do
    io.puts "\n\nSONGLIST - orphaned"
    Songlist.orphaned 
    |> Enum.join("\n") 
    |> io.puts
  end

  # private

  defp all_files do
    Mp3Proxy.all
  end

end
