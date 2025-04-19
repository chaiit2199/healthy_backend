defmodule HealthyBackend.Diseases do
  use Ecto.Schema
  import Ecto.Changeset
  alias HealthyBackend.Repo
  import Ecto.Query, only: [from: 2]

  schema "types_diseases" do
    field :title, :string
    field :name, :string
    field :data, :string
    field :treatments, :string
    timestamps()
  end

  def changeset(diseases, attrs, opts \\ []) do
    diseases
    |> cast(attrs, [:title, :name, :data])
    |> validate_required([:title, :name, :data])
  end

  def create_diseases(attrs) do
    %HealthyBackend.Diseases{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def search_diseases(query) do
    from(s in HealthyBackend.Diseases,
      where: ilike(s.title, ^"%#{query}%"),
      order_by: fragment("LENGTH(?) ASC", s.title),
      limit: 1
    )
    |> Repo.one()
  end

  def get_diseases_names do
    from(d in HealthyBackend.Diseases,
      select: d.name
    )
    |> Repo.all()
  end

  def get_by_name(name) do
    from(d in HealthyBackend.Diseases,
      where: d.name == ^name
    )
    |> Repo.one()
  end

  def get_recent_diseases(limit \\ 3) do
    from(d in HealthyBackend.Diseases,
      order_by: [desc: d.inserted_at],
      limit: ^limit
    )
    |> Repo.all()
  end
end
