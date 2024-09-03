defmodule RyancirishWeb.PageController do
  use RyancirishWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def about(conn, _params) do
    render(conn, :about, layout: false)
  end

  def show(conn, _params) do
    render(conn, "show.html", layout: false)
  end

  def index(conn, _params) do
    pages = RyancirishWeb.Router.get_pages!(:blog)

    conn
    |> assign(:pages, pages)
    |> render("index.html", layout: false)
  end
end
