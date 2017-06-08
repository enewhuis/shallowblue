defmodule Shallowblue.PublicUserView do
  use Shallowblue.Web, :view

  def render("show.json", user_info) do
    %{data: render_one(user_info, Shallowblue.PublicUserView, "user.json")}
  end

  def render("user.json", user_info) do
    %{user: user, jwt: jwt, exp: exp} = user_info.public_user
    %{id: user.id,
      fullname: user.fullname,
      jwt: jwt,
      exp: exp}
  end
end
