defmodule Etlien.Router do
  use Etlien.Web, :router

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

  scope "/", Etlien do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  # scope "/api", Etlien do
  #   pipe_through :api
  #   post "/set/:set_id", Api.Set
  # end

end
