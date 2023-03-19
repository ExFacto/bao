defmodule BaoWeb.Router do
  # alias BaoWeb.EventController
  use BaoWeb, :router

  # api must be defined first because all other paths redirect to /docs
  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", BaoWeb do
    pipe_through :api

    get "/oracle", OracleController, :index

    # lookup event
    get "/event", EventController, :show
    # create / verify event
    post "/event", EventController, :create
    # post signature to event
    put "/event", EventController, :update
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    # plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", BaoWeb do
    pipe_through :browser

    get "/docs", DocsController, :index
    # redirect all traffic to docs
    # get "/*path", Plugs.DocsRedirector, :call
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  # if Mix.env() in [:dev, :test] do
  #   import Phoenix.LiveDashboard.Router

  #   scope "/" do
  #     pipe_through [:fetch_session, :protect_from_forgery]

  #     live_dashboard "/dashboard", metrics: BaoWeb.Telemetry
  #   end
  # end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  # if Mix.env() == :dev do
  #   scope "/dev" do
  #     pipe_through [:fetch_session, :protect_from_forgery]

  #     forward "/mailbox", Plug.Swoosh.MailboxPreview
  #   end
  # end
end
