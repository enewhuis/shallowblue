defmodule Shallowblue.MatchTest do
  use Shallowblue.ModelCase

  alias Shallowblue.Match

  @valid_attrs %{player1_id: 1, player2: nil}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Match.changeset(%Match{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Match.changeset(%Match{}, @invalid_attrs)
    refute changeset.valid?
  end
end
