defmodule Shallowblue.MatchChannel do
  use Shallowblue.Web, :channel

  alias Shallowblue.Match

  def join("match:" <> match_id = topic, %{"guardian_token" => token}, socket) do
    case sign_in(socket, token) do
      {:ok, authed_socket, _guardian_params} ->
	user_id = String.to_integer(authed_socket.id)
	case Repo.get Match, match_id do
	  nil ->
	    {:error, %{reason: "Match Not Found"}}
	  match ->
	    {match, message} = cond do
	      user_id == match.player1_id ->
		{match, "rejoined"}
	      user_id == match.player2_id ->
		{match, "rejoined"}
	      !match.player2_id ->
		{Repo.update!(Match.changeset(match, %{player2_id: user_id})), "joined"}
	      true ->
		{match, "watching"}
	    end
	    {:ok, %{message: message, status: Match.status(match), moves: match.moves}, authed_socket}
	end
      {:error, reason} ->
	{:error, %{reason: reason}}
    end
  end

  def join(_match_id, _, _socket) do
    {:error,  :authentication_required}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("status", _payload, socket) do
    match = get_match socket
    info = %{
      status: Match.status(match),
      moves: match.moves
    }
    {:reply, {:ok, info}, socket}
  end

  # Broadcast move to all clients of the topic ("match:#{Match.id}").
  def handle_in("move", move, socket) do
    user_id = String.to_integer(socket.id)
    match = get_match socket
    if user_id == match.player1_id or user_id == match.player2_id do
      Repo.update! Match.changeset(match, %{moves: [move|match.moves]})
      broadcast socket, "move", %{player: socket.id, move: move}
    end
    {:noreply, socket}
  end

  def get_match(socket) do
    "match:" <> match_id = socket.topic
    Repo.get! Match, match_id
  end

end
