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

  def blog(conn, _params) do
    render(conn, :blog, layout: false)
  end
end
