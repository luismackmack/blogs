defmodule BlogSystrix.Comment do
  use BlogSystrix.Web, :model

  schema "comments" do
    field :name, :string
    field :content, :string
    belongs_to :user, BlogSystrix.User, foreign_key: :user_id
    belongs_to :post, BlogSystrix.Post, foreign_key: :post_id

    timestamps
  end

  @required_fields ~w(content user_id post_id)
  @optional_fields ~w(name)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
