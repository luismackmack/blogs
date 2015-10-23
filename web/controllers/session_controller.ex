defmodule BlogSystrix.SessionController do
  use BlogSystrix.Web, :controller

  alias BlogSystrix.User

  plug :scrub_params, "user" when action in [:create]

  def new(conn, _params) do
    render conn, changeset: User.changeset(%User{})
  end

  def create(conn, %{"user" => user_params}) do
    user = if is_nil(user_params["email"]) do
      nil
    else
      Repo.get_by(User, email: user_params["email"])
    end

    user
      |> sign_in(user_params["password"], conn)
  end

  def delete(conn, _) do
    delete_session(conn, :current_user)
      |> put_flash(:info, 'Se ha deslogueado')
      |> redirect(to: session_path(conn, :new))
  end

  defp sign_in(user, password, conn) when is_nil(user) do
    conn
      |> put_flash(:error, 'Usuario no registrado.')
      |> render "new.html", changeset: User.changeset(%User{})
  end

  defp sign_in(user, password, conn) when is_map(user) do
    cond do
      Comeonin.Bcrypt.checkpw(password, user.encrypted_password) ->
        conn
          |> put_session(:current_user, user)
          |> put_layout("logged_in.html")
          |> put_flash(:info, 'Se ha logueado.')
          |> redirect(to: post_path(conn, :index))
      true ->
        conn
          |> put_flash(:error, 'Email o password incorrectos.')
          |> render "new.html", changeset: User.changeset(%User{})
    end
  end
end