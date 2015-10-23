defmodule BlogSystrix.User do
  use BlogSystrix.Web, :model

  schema "users" do
    field :nombre, :string
    field :email, :string
    field :encrypted_password, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    has_many :posts, BlogSystrix.Post
    has_many :comments, BlogSystrix.Comment

    timestamps
  end

  @required_fields ~w(nombre email password password_confirmation)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_unique(:email, on: BlogSystrix.Repo, downcase: true)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 5)
    |> validate_length(:password_confirmation, min: 5)
    |> validate_confirmation(:password)
  end
end
