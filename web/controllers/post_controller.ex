defmodule BlogSystrix.PostController do
  use BlogSystrix.Web, :controller
  
  alias BlogSystrix.User
  alias BlogSystrix.Post
  alias BlogSystrix.Comment
  plug BlogSystrix.Plug.Authenticate
  plug :scrub_params, "post" when action in [:create, :update]
  plug :scrub_params, "comment" when action in [:add_comment]


  def index(conn, _params) do
    current_user_id = Plug.Conn.get_session(conn, :current_user).id
    query = from p in Post, where: p.user_id == ^current_user_id
    query = Post.count_comments(query) 
    posts_user = Repo.all(query)
    query2 = from p in Post, where: p.user_id != ^current_user_id
    query2 = Post.count_comments(query2) 
    other_posts = Repo.all(query2)
    conn
    |> put_layout("logged_in.html")
    |> render("index.html", posts_user: posts_user, other_posts: other_posts)
  end

  def new(conn, _params) do
    changeset = Post.changeset(%Post{})
    conn
    |> put_layout("logged_in.html")
    |> render("new.html", changeset: changeset)
  end

  def create(conn, %{"post" => post_params}) do
    current_user_id = Plug.Conn.get_session(conn, :current_user).id
    changeset = Post.changeset(%Post{}, Map.put(post_params, "user_id", current_user_id))
    case Repo.insert(changeset) do
      {:ok, _post} ->
        conn
        |> put_layout("logged_in.html")
        |> put_flash(:info, "Post creado satisfactoriamente.")
        |> redirect(to: post_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def add_comment(conn, %{"comment" => comment_params, "post_id" => post_id}) do
    current_user_id = Plug.Conn.get_session(conn, :current_user).id
    comment_params = Map.put(comment_params, "post_id", post_id)
    comment_params = Map.put(comment_params, "user_id", current_user_id)
    changeset = Comment.changeset(%Comment{}, comment_params)
    post = Post |> Repo.get(post_id) |> Repo.preload([:comments])
    case Repo.insert(changeset) do
      {:ok, comment} ->
        conn
        |> put_layout("logged_in.html")
        |> put_flash(:info, "El comentario ha sido agregado correctamente.")
        |> redirect(to: post_path(conn, :show, post))
      {:error, changeset} ->
        render(conn, "show.html", post: post, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    #post = Repo.get!(Post, id) |> Repo.preload([:comments])
    post = Repo.get!(Post, id) |> Repo.preload([comments: :user])
    IO.inspect "--- Imprimiendo por consola lo que genera el query ---"
    IO.inspect post
    changeset = Comment.changeset(%Comment{})
    conn
    |> put_layout("logged_in.html")
    |> render("show.html", post: post, changeset: changeset)
  end

  def edit(conn, %{"id" => id}) do
    post = Repo.get!(Post, id)
    changeset = Post.changeset(post)
    conn
    |>  put_layout("logged_in.html")
    render(conn, "edit.html", post: post, changeset: changeset)
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    post = Repo.get!(Post, id)
    changeset = Post.changeset(post, post_params)

    case Repo.update(changeset) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post actualizado satisfactoriamente.")
        |> redirect(to: post_path(conn, :show, post))
      {:error, changeset} ->
        render(conn, "edit.html", post: post, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    post = Repo.get!(Post, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(post)

    conn
    |> put_flash(:info, "Post borrado satisfactoriamente.")
    |> redirect(to: post_path(conn, :index))
  end
end
