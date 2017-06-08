defmodule Shallowblue.MatchChannelTest do
  use Shallowblue.ChannelCase

  alias Shallowblue.User
  alias Shallowblue.Match
  alias Shallowblue.MatchChannel

  setup do
    %{alice: new_user(), bob: new_user(), charlie: new_user()}
  end

  test "player1 join match and verify status waiting", u do
    match = Repo.insert! %Match{player1_id: u.bob.id}
    {:ok, info, _socket} = join_match(u.bob, match)
    assert info.status == "waiting"
  end

  test "player2 join match and verify status playing", u do
    match = Repo.insert! %Match{player1_id: u.bob.id}
    {:ok, info, _socket} = join_match(u.alice, match)
    assert info.status == "playing"
  end

  test "user3 join match and verify status watching", u do
    match = Repo.insert! %Match{player1_id: u.bob.id}
    {:ok, _, _socket} = join_match(u.alice, match)
    {:ok, info, _socket} = join_match(u.charlie, match)
    assert info.status == "playing"
    assert info.message == "watching"
  end

  test "explicitly request match status", u do
    match = Repo.insert! %Match{player1_id: u.bob.id}
    {:ok, _info, socket1} = join_match(u.bob, match)
    ref1 = push socket1, "status", %{}
    assert_reply ref1, :ok, %{status: "waiting"}
    {:ok, _info, socket2} = join_match(u.alice, match)
    ref2 = push socket2, "status", %{}
    assert_reply ref2, :ok, %{status: "playing"}
  end

  test "broadcast moves through match:* channel", u do
    match = Repo.insert! %Match{player1_id: u.bob.id}
    {:ok, _, socket1} = join_match(u.bob, match)
    {:ok, _, socket2} = join_match(u.alice, match)    
    push socket1, "move", "e4"
    assert_broadcast "move", %{move: "e4"}
    push socket2, "move", "e5"
    assert_broadcast "move", %{move: "e5"}
    {:ok, info, socket3} = join_match(u.charlie, match)
    assert info.moves == ["e5", "e4"]
    push socket3, "move", "Nf3"
    refute_broadcast "move", %{move: "Nf3"}
    push socket1, "move", "Nf3"
    assert_broadcast "move", %{move: "Nf3"}
  end

  def new_user() do
    user = Repo.insert! %User{}
    {:ok, jwt, _claims} = Guardian.encode_and_sign(user)
    %{user: user, id: user.id, jwt: jwt}
  end
  
  def join_match(user, match) do
    socket = socket("#{user.user.id}", %{})
    subscribe_and_join(socket,
      MatchChannel,
      "match:#{match.id}",
      %{"guardian_token" => "#{user.jwt}"})
  end

end
