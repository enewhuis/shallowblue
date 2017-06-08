defmodule Shallowblue.PageControllerTest do
  use Shallowblue.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Welcome to Shallow Blue Chess!"
  end
end
