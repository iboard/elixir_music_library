defmodule Mp3Repo do
  @moduledoc """
  The source of files is given by a starting path.
  The set holds the entries itself. Where each entry is a filename and a
  function to be called to extract ID3 part from the given file.
  """
  defstruct path: ".", set: MapSet.new
end
