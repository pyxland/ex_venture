defmodule Game.NPC.Actions.CommandsTargetTest do
  use Data.ModelCase

  alias Data.Events.Actions
  alias Game.Character
  alias Game.NPC.State
  alias Game.NPC.Actions.CommandsTarget

  doctest CommandsTarget

  setup do
    %{state: %State{npc: npc_attributes(%{id: 1}), room_id: 1}}
  end

  describe "acting" do
    test "targets the player", %{state: state} do
      player = %Character.Simple{type: :npc, id: 1}
      action = %Actions.CommandsTarget{
        options: %{player: true, character: {:player, player}}
      }

      {:ok, state} = CommandsTarget.act(state, action)

      assert state.combat
      assert state.target
    end

    test "will not target the player", %{state: state} do
      player = %Character.Simple{type: :npc, id: 1}
      action = %Actions.CommandsTarget{
        options: %{player: false, character: {:player, player}}
      }

      {:ok, state} = CommandsTarget.act(state, action)

      refute state.combat
      refute state.target
    end

    test "targets an npc", %{state: state} do
      npc = %Character.Simple{type: :npc, id: 1}
      action = %Actions.CommandsTarget{
        options: %{npc: true, character: {:npc, npc}}
      }

      {:ok, state} = CommandsTarget.act(state, action)

      assert state.combat
      assert state.target
    end

    test "will not target an npc", %{state: state} do
      npc = %Character.Simple{type: :npc, id: 1}
      action = %Actions.CommandsTarget{
        options: %{npc: false, character: {:npc, npc}}
      }

      {:ok, state} = CommandsTarget.act(state, action)

      refute state.combat
      refute state.target
    end

    test "already in combat", %{state: state} do
      state = %{state | combat: true}

      player = %Character.Simple{id: 1}
      action = %Actions.CommandsTarget{
        options: %{player: true, character: {:player, player}}
      }

      {:ok, state} = CommandsTarget.act(state, action)

      assert state.combat
      refute state.target
    end

    test "already has a target", %{state: state} do
      player = %Character.Simple{id: 1}
      action = %Actions.CommandsTarget{
        options: %{player: true, character: {:player, player}}
      }

      state = %{state | target: {:player, player}}

      {:ok, state} = CommandsTarget.act(state, action)

      refute state.combat
      assert state.target
    end
  end
end
