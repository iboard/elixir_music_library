MP3 Library
===========

Simple Music Library written in Elixir.
It reads all ID3 tags from files found in a given path [recursively]


Quick start
===========

    $ git clone git@github.com:iboard/elixir_music_library.git
    $ cd elixir_music_library
    $ mix deps.get

    $ mix test
    ...

    Finished in 0.1 seconds (0.07s on load, 0.1s on tests)
    3 tests, 0 failures

    Randomized with seed 85739

    $ mix scs -p test/ -l
    8 files to execute......... done.


    SONGLIST - all
    0978179A555624680D67D2821366D5D7612A7898DCE3B55995DCEFB44AE07244 => %{album: "Clinophobia", artist: "Devil's Slingshot", file: "test/fixtures/nederland.mp3", title: "Nederland"}
    124ECA0D4EE1B9A35DF4C4150402E1D44C68E9CCB093FC92DE21F66E0C0C5E01 => %{album: "LA Woman", artist: "the doors", file: "test/fixtures/LA Woman/1971 - L.A.Woman_Shaw/02 - Love Her Madly - The doors.mp3", title: "love her madly"}
    720ED42E5054635C3A0A9099B8C809D5F59ABCDDF9C9962884C90F32F975C632 => %{album: "Blunderbuss", artist: "Jack White", file: "test/fixtures/Jack White - Blunderbuss 2013/03 Freedom at 21.mp3", title: "Freedom at 21"}
    7B53022265F6B510AC1E1D044433A61CBA40D1DF057B30DA90A54A2DB4C0CAA2 => %{album: "LA Woman", artist: "the doors", file: "test/fixtures/LA Woman/1971 - L.A.Woman_Shaw/03 - Been Down So Long - The doors.mp3", title: "been down so long"}
    9BAF21F2D29434A1C87586E20FA984DEA6D2CD2544E0B62CCAAFDAB1B0190D97 => %{album: "The Essential (CD1)", artist: "The Clash", file: "test/fixtures/15-English Civil War.mp3", title: "English Civil War"}
    AF093F480AB838457A35B88001C9AB71279A570E2B48154211C79E9E1CF31F9D => %{album: "Blunderbuss", artist: "Jack White", file: "test/fixtures/Jack White - Blunderbuss 2013/02 Sixteen Saltines.mp3", title: "Sixteen Saltines"}
    D7FE302FF2454543082D5418FF48FF7BFA04E859FF8A0CD2B17E7296BF7DDC31 => %{album: "LA Woman", artist: "the doors", file: "test/fixtures/LA Woman/1971 - L.A.Woman_Shaw/01 - The Changeling - The doors.mp3", title: "the changeling"}
    FAAAB2A61A7B4CF22FA09AEBC6951976336CE64B88C179223D72B9A033B165C7 => %{album: "Blunderbuss", artist: "Jack White", file: "test/fixtures/Jack White - Blunderbuss 2013/01 Missing Pieces.mp3", title: "Missing Pieces"}

    $ mix scs -p test/ -h
    Options:
      h: :help,  ............... print this screen
      l: :list_all,............. List entire repository
      p: :path, ................ path to files MANDATORY
      i: :list_interpreters, ... output interpreter list
      o: :list_orphands,........ output orphaned entries
      a: :list_albums .......... output album list

Get Started
===========

see file `lib/mix/tasks/scs.ex` how to use this library.
