defmodule Shallowblue.Router do
  use Shallowblue.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_auth do
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
  end

  scope "/", Shallowblue do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/api", Shallowblue do
    pipe_through :api

    resources "/users", PublicUserController, except: [:new, :edit, :index, :show, :update, :delete]
  end

  scope "/api", Shallowblue do
    pipe_through [:api, :api_auth]

    resources "/users", UserController, except: [:new, :edit, :create]
    resources "/matches", MatchController, except: [:new, :edit]
  end
end
