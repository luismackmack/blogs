defmodule BlogSystrix.Password do
  alias BlogSystrix.Repo
  import Ecto.Changeset, only: [put_change: 3]
  import Comeonin.Bcrypt, only: [hashpwsalt: 1]

  @doc """
    genera un password por el usuario y lo almacenaen el changeset como encrypted_password.
  """

  def generate_password(changeset) do
    put_change(changeset, :encrypted_password, hashpwsalt(changeset.params["password"]))
  end

  @doc """
    Genera el password por el changeset y lo guarda en la database.
  """
  def generate_password_and_store(changeset) do
    changeset
      |> generate_password
      |> Repo.insert
  end
end