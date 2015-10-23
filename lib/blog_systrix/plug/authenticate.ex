defmodule BlogSystrix.Plug.Authenticate do
  import Plug.Conn
  import BlogSystrix.Router.Helpers
  import Phoenix.Controller

  def init(default), do: default

  def call(conn, default) do
    current_user = get_session(conn, :current_user)
    if current_user do
      assign(conn, :current_user, current_user)
    else
      conn
        |> put_flash(:error, 'Debe loguearse para poder acceder a la página especificada')
        |> redirect(to: session_path(conn, :new))
    end
  end
end