defmodule Shallowblue.UserView do
  use Shallowblue.Web, :view

  def render("error.json", %{message: message}) do
    %{error: message}
  end

  def render("index.json", %{users: users}) do
    %{data: render_many(users, Shallowblue.UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, Shallowblue.UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      fullname: user.fullname}
  end
end
