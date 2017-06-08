defmodule Shallowblue.MatchControllerTest do
  use Shallowblue.ConnCase

  alias Shallowblue.User
  alias Shallowblue.Match

  @invalid_attrs %{player1_id: nil, player2_id: nil}

  setup %{conn: conn} do
    user = Repo.insert! %User{}
    {:ok, jwt, _claims} = Guardian.encode_and_sign(user)
    conn =
      conn
      |> put_req_header("authorization", "Bearer #{jwt}")
      |> put_req_header("accept", "application/json")
    {:ok, %{conn: conn, user: user}}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, match_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    match = Repo.insert! %Match{} |> Repo.preload([:player1, :player2])
    conn = get conn, match_path(conn, :show, match)
    assert json_response(conn, 200)["data"] == %{"id" => match.id,
      "player1_id" => match.player1_id,
      "player2_id" => match.player2_id}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, match_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    user = Repo.insert! %User{}
    valid = %{player1_id: user.id}
    conn = post conn, match_path(conn, :create), match: valid
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Match, valid)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, match_path(conn, :create), match: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    user = Repo.insert! %User{}
    valid = %{player1_id: user.id}
    match = Repo.insert! %Match{}
    conn = put conn, match_path(conn, :update, match), match: valid
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Match, valid)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    match = Repo.insert! %Match{} |> Repo.preload([:player1, :player2])
    conn = put conn, match_path(conn, :update, match), match: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    match = Repo.insert! %Match{} |> Repo.preload([:player1, :player2])
    conn = delete conn, match_path(conn, :delete, match)
    assert response(conn, 204)
    refute Repo.get(Match, match.id)
  end

  test "match states", %{conn: conn} do
    player1 = Repo.insert! %User{}
    waiting = Match.changeset(%Match{}, %{player1_id: player1.id})
    {:ok, match} = Repo.insert(waiting)
    match1 = Repo.preload(match, [:player1, :player2])

    conn1 = get conn, match_path(conn, :index)
    assert json_response(conn1, 200)["data"] == [%{"id" => match.id, "player1_id" => player1.id, "player2_id" => nil}]
    conn2 = get conn, match_path(conn, :index, q: "waiting")
    assert json_response(conn2, 200)["data"] == [%{"id" => match.id, "player1_id" => player1.id, "player2_id" => nil}]
    conn3 = get conn, match_path(conn, :index, q: "playing")
    assert json_response(conn3, 200)["data"] == []
    conn4 = get conn, match_path(conn, :index, q: "finished")
    assert json_response(conn4, 200)["data"] == []

    player2 = Repo.insert! %User{}
    playing = Match.changeset(match1, %{player2_id: player2.id})
    {:ok, match2} = Repo.update(playing)
    conn1 = get conn, match_path(conn, :index)
    assert json_response(conn1, 200)["data"] == [%{"id" => match.id, "player1_id" => player1.id, "player2_id" => player2.id}]
    conn2 = get conn, match_path(conn, :index, q: "waiting")
    assert json_response(conn2, 200)["data"] == []
    conn3 = get conn, match_path(conn, :index, q: "playing")
    assert json_response(conn3, 200)["data"] == [%{"id" => match.id, "player1_id" => player1.id, "player2_id" => player2.id}]
    conn4 = get conn, match_path(conn, :index, q: "finished")
    assert json_response(conn4, 200)["data"] == []

    finished = Match.changeset(match2, %{finished_at: DateTime.utc_now})
    {:ok, _match3} = Repo.update(finished)
    conn1 = get conn, match_path(conn, :index)
    assert json_response(conn1, 200)["data"] == [%{"id" => match.id, "player1_id" => player1.id, "player2_id" => player2.id}]
    conn2 = get conn, match_path(conn, :index, q: "waiting")
    assert json_response(conn2, 200)["data"] == []
    conn3 = get conn, match_path(conn, :index, q: "playing")
    assert json_response(conn3, 200)["data"] == []
    conn4 = get conn, match_path(conn, :index, q: "finished")
    assert json_response(conn4, 200)["data"] == [%{"id" => match.id, "player1_id" => player1.id, "player2_id" => player2.id}]    
  end

end
