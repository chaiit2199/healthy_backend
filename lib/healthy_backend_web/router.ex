defmodule HealthyBackendWeb.Router do
  use HealthyBackendWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {HealthyBackendWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    # plug Restrict.AllowsOrigin
    plug :accepts, ["json"]
  end

  scope "/api", HealthyBackendWeb do
    pipe_through :api

    get "/ai", AIController, :index
    get "/diseases", AIController, :get
    get "/recent_diseases", AIController, :get_recent_diseases
    get "/category", AIController, :get_category_posts
  end

  scope "/", HealthyBackendWeb do
    pipe_through :browser

    live("/", HomeLive, :index)
  end
end
