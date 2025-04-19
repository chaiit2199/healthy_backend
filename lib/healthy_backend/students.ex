defmodule HealthyBackend.Students do
  use Ecto.Schema
  import Ecto.Changeset
  alias HealthyBackend.Repo
  import Ecto.Query, only: [from: 2]

  schema "students" do
    field :name, :string
    field :email, :string
    timestamps()
  end

  def changeset(student, attrs, opts \\ []) do
    student
    |> cast(attrs, [:name, :email])
    |> validate_required([:name, :email])
    |> validate_format(:email, ~r/@/, message: "Email must contain '@'.")
  end

  def create_student(attrs) do
    %HealthyBackend.Students{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def search_student(query) do
    from(s in HealthyBackend.Students,
      where:
        fragment(
          "to_tsvector('english', ?) @@ websearch_to_tsquery('english', ?)",
          s.name,
          ^query
        ),
      order_by:
        fragment(
          "ts_rank_cd(to_tsvector('english', ?), websearch_to_tsquery('english', ?)) DESC, LENGTH(?) ASC",
          s.name,
          ^query,
          s.name
        ),
      limit: 1
    )
    |> Repo.one()
  end
end
