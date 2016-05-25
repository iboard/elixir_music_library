defmodule Mix.Tasks.Scs do
  @moduledoc """
  """

  use Mix.Task

  @shortdoc "SCS: List directory as ID3 List"
  def run(args) do
    { opts, _, _ } = OptionParser.parse(args,
                       aliases: [
                         p: :path, 
                         d: :dirnames,
                         q: :quiet, 
                         e: :empty, 
                         i: :ids,
                         f: :filenames,
                         l: :log,
                         o: :output,
                         c: :copy,
                         s: :summarize
                       ]
                     )

    IO.puts "Parsing MP3 files with options:"
    IO.puts "  source path -p #{opts[:path]}"
    IO.puts "  quiet, no errors -q  #{opts[:quiet] || false}"
    IO.puts "  output empty tags -e  #{opts[:empty] || false}"
    IO.puts "  add ids -i #{opts[:ids]   || false}"
    IO.puts "  output original filename -f #{opts[:filenames] || false}"
    IO.puts "  output original path -d #{opts[:dirnames] || false}"
    IO.puts "  output prefix -o #{opts[:output] || false}"
    IO.puts "  output log -l #{opts[:log] || false}"
    IO.puts "  copy to output path -c #{opts[:copy] || false}"
    IO.puts "  summarize -s #{opts[:summarize] || false}"

    Mp3File.list(opts[:path])
      |> Enum.reduce( %{next_id: 1}, fn song, acc -> 
           next_id = acc[:next_id]
           sum     = acc[:sum] || %{count: 0, size: 0}
           { count, _ } = case parse_mp3_file(song,opts) do
                 { :ok, tags }         -> { 1, add_id(tags,opts,next_id) |>  copy_file(song,opts) |> add_stats }
                 { :invalid, _tags }   -> { 0, if(opts[:empty], do: IO.puts "EMPTY: #{song}") }
                 { :error, message }   -> { 0, unless(opts[:quiet], do: IO.puts "ERROR: #{message}") }
                 _ -> { 0, "unhandled error" }
           end
           %{ next_id: next_id+count }
         end)
      |> inspect
      |> IO.puts
  end

  defp summarize tags, acc, opts do
    if(opts[:summarize]) do
      Map.put( tags, :summarize, %{ size: acc[:size] + 1} )
      [tags, acc]
    end
  end

  defp add_stats(tags) do

  end

  defp copy_file tags, song, opts do
    source = Path.join(tags[:path], tags[:file])
    target = Path.join(opts[:output], tags[:artist])
             |> Path.join(tags[:album])
             |> Path.join(sanitize("#{:io_lib.format("~5B_~ts.mp3",[tags[:_id_],tags[:title]])}"))
    prefix = if(opts[:copy], do: "COPY", else: "FOUND")
    if(opts[:log], do: IO.puts "#{prefix} #{source} TO #{target}")
    if(opts[:copy], do: copy(source,target))
    tags
  end

  defp copy source, target do
    dir = Path.dirname(target)
    ensure_path(dir)
    copy_file(source, target)
  end

  defp copy_file(source,target) do
    File.cp(source,target)
  end

  defp ensure_path dir do
    case File.mkdir_p(dir) do
      :ok -> { "Path ok" }
      {:error, posix} -> { IO.puts "ERROR MKDIR #{posix}" }
      _ -> { IO.puts "UNKNOWN STATE" }
    end
  end

  defp sanitize input do
    String.strip(input)
    |> String.replace( ~r/\s+/, "_" )
    |> String.replace( ~r/'/, "_" )
    |> String.replace( ~r/_+/, "_" )
    |> String.replace( ~r/[\(\)]/, "-" )
  end

  defp add_id tags, opts, id do
    if(opts[:ids], do: Map.put(tags, :_id_, id), else: tags)
  end

  defp output tags do
    tags |> inspect |> IO.puts
    tags
  end
  defp parse_mp3_file(song,opts) do
    try do
      Mp3File.extract_id3(song) |> validate_tags(song,opts)
    rescue
      UnicodeConversionError -> { :error, "UTF-8 Error in #{song}'s MP3 tags" }
    end
  end

  defp validate_tags %{album: "", artist: "", title: ""}, file, _opts do
    { :invalid, file }
  end
  defp validate_tags tags, file, opts do
    { :ok, tags |> add_path(opts,file) |> add_file(opts,file) }
  end

  defp add_path tags, opts, file do
    if opts[:dirnames] do
      tags |> Map.put(:path, Path.dirname(file)) 
    else
      tags
    end
  end
  defp add_file tags, opts, file do
    if opts[:filenames] do
      tags |> Map.put(:file, Path.basename(file)) 
    else
      tags
    end
  end

end
