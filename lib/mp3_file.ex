defmodule Mp3File do
  @moduledoc """
  Handle MP3 files
  Credit and Copyright: https://github.com/anisiomarxjr/shoutcast-server
  """


  @doc "Extract id3 section from binary file"
  def extract_metadata(filename) do
    File.read!(filename) |> split_binary()
  end

  def extract_id3(filename) do
    metadata = extract_metadata(filename)
    parse_id3(metadata)
  end

  def extract_id3_list(folder) do
    folder |> all() |> Enum.map(&extract_id3/1)
  end

  def all(folder) do
    folder |> Path.join("**/*.mp3") |> Path.wildcard
  end

  defp parse_id3(metadata) do
    << _      :: binary-size(3),
       title  :: binary-size(30),
       artist :: binary-size(30),
       album  :: binary-size(30),
       _      :: binary 
    >> = metadata

    %{
      title: sanitize(title),
      artist: sanitize(artist),
      album: sanitize(album)
    }
  end

  defp sanitize(text) do
    not_zero = &(&1 != <<0>>)
    text 
      |> String.graphemes 
      |> Enum.filter(not_zero) 
      |> to_string 
      |> String.trim
  end

  defp split_binary( data ) do
    file_length = byte_size(data)
    music_data = file_length - 128
    << _ :: binary-size(music_data), id3_section :: binary >> = data
    id3_section
  end

end
