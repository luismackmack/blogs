defmodule BlogSystrix.RegistrationController do
  use BlogSystrix.Web, :controller
  alias BlogSystrix.Password
  alias BlogSystrix.User
  plug :scrub_params, "user" when action in [:create]
  plug :action

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render conn, changeset: changeset
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.changeset(%User{}, user_params)
    if changeset.valid? do
      new_user = Password.generate_password_and_store(changeset)
      IO.inspect new_user
      new_user = elem(new_user, 1)
      conn
        |> put_flash(:info, "Registrado Satisfactoriamente y Logueado")
        |> put_session(:current_user, new_user)
        |> redirect(to: post_path(conn, :index))
    else
      render conn, "new.html", changeset: changeset
    end
  end
end