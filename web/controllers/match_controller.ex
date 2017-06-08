defmodule Shallowblue.MatchController do
  use Shallowblue.Web, :controller

  plug EnsureAuthenticated

  alias Shallowblue.Match
  
  def index(conn, params) do
    matches = case params["q"] do
		nil -> Repo.all(Match)
		"waiting" -> Repo.all(Ecto.Query.from(d in Match, where: is_nil(d.player2_id)))
		"playing" -> Repo.all(Ecto.Query.from(d in Match, where: not(is_nil(d.player2_id)) and is_nil(d.finished_at)))
		"finished" -> Repo.all(Ecto.Query.from(d in Match, where: not(is_nil(d.finished_at))))
	      end
    render(conn, "index.json", matches: matches)
  end

  def create(conn, %{"match" => match_params}) do
    changeset = Match.changeset(%Match{}, match_params)
    case Repo.insert(changeset) do
      {:ok, match0} ->
	match = Repo.preload(match0, [:player1, :player2])
        conn
        |> put_status(:created)
        |> put_resp_header("location", match_path(conn, :show, match))
        |> render("show.json", match: match)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Shallowblue.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    match = Repo.get!(Match, id) |> Repo.preload([:player1, :player2])
    render(conn, "show.json", match: match)
  end

  def update(conn, %{"id" => id, "match" => match_params}) do
    match = Repo.get!(Match, id) |> Repo.preload([:player1, :player2])
    changeset = Match.changeset(match, match_params)

    case Repo.update(changeset) do
      {:ok, match0} ->
	match = Repo.preload(match0, [:player1, :player2])
        render(conn, "show.json", match: match)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Shallowblue.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    match = Repo.get!(Match, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(match)

    send_resp(conn, :no_content, "")
  end
end
