defmodule BlogSystrix.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :encrypted_password, :string
      add :nombre, :string
      add :email, :string

      timestamps
    end

  end
end
