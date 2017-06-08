defmodule Shallowblue.MatchView do
  use Shallowblue.Web, :view

  def render("index.json", %{matches: matches}) do
    %{data: render_many(matches, Shallowblue.MatchView, "match.json")}
  end

  def render("show.json", %{match: match}) do
    %{data: render_one(match, Shallowblue.MatchView, "match.json")}
  end

  def render("match.json", %{match: match}) do
    %{id: match.id,
      player1_id: match.player1_id,
      player2_id: match.player2_id}
  end
end
