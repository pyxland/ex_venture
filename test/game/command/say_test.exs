defmodule Game.Command.SayTest do
  use ExVenture.CommandCase

  alias Game.Command.Say
  alias Game.Command.Say.ParsedMessage

  doctest Say

  setup do
    user = create_user(%{name: "user", password: "password"})
    character = create_character(user)
    %{state: session_state(%{user: user, character: character, save: character.save})}
  end

  describe "say" do
    test "say to the", %{state: state} do
      :ok = Say.run({"hi"}, state)

      assert_socket_echo ~s("hi.")
    end
  end

  describe "say with an adverb phrase" do
    test "appends to after", %{state: state} do
      :ok = Say.run({"[softly] hi"}, state)

      assert_socket_echo "say softly,"
    end
  end

  describe "say to someone" do
    test "to a player", %{state: state} do
      player = %{id: 1, name: "Player"}
      start_room(%{players: [player]})

      :ok = Say.run({">player hi"}, state)

      assert_socket_echo ~s("hi.")
    end

    test "to an npc", %{state: state} do
      guard = create_npc(%{name: "Guard"})
      start_room(%{npcs: [guard]})

      :ok = Say.run({">guard hi"}, state)

      assert_socket_echo ~s("hi.")
    end

    test "target not found", %{state: state} do
      start_room(%{})

      :ok = Say.run({">guard hi"}, state)

      assert_socket_echo "no .+ could be found"
    end
  end

  describe "parsing a say message" do
    test "simple" do
      assert %ParsedMessage{message: "hello"} = Say.parse_message("hello")
      assert %ParsedMessage{adverb_phrase: nil} = Say.parse_message("hello")
    end

    test "strips surrounding quotes" do
      assert %ParsedMessage{message: "hello"} = Say.parse_message("\"hello\"")
    end

    test "directed at someone" do
      assert %ParsedMessage{message: "guard hello", is_directed: true} = Say.parse_message(">guard hello")
    end

    test "adverb phrase" do
      assert %ParsedMessage{adverb_phrase: "softly"} = Say.parse_message("[softly] hello")
      assert %ParsedMessage{message: "hello"} = Say.parse_message("[softly] hello")
    end

    test "adverb phrase is first" do
      assert %ParsedMessage{adverb_phrase: nil, message: "hello \\[softly\\]"} = Say.parse_message("hello [softly]")
      assert %ParsedMessage{adverb_phrase: nil, message: "hello \\[softly\\]"} = Say.parse_message("  hello [softly]")
    end
  end
end
