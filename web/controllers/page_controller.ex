defmodule BlogSystrix.PageController do
  use BlogSystrix.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
