defmodule Shallowblue.PublicUserController do
  use Shallowblue.Web, :controller

  alias Shallowblue.User

  def create(conn, %{"user" => user_params}) do
    changeset = User.changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, user} ->
	new_conn = Guardian.Plug.api_sign_in(conn, user)
	jwt = Guardian.Plug.current_token(new_conn)
	{:ok, claims} = Guardian.Plug.claims(new_conn)
	exp = Map.get(claims, "exp")

	new_conn
        |> put_status(:created)
	|> put_resp_header("authorization", "Bearer #{jwt}")
	|> put_resp_header("x-expires", "#{exp}")
        |> put_resp_header("location", user_path(new_conn, :show, user))
	|> render("show.json", user: user, jwt: jwt, exp: exp)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Shallowblue.ChangesetView, "error.json", changeset: changeset)
    end
  end

end
