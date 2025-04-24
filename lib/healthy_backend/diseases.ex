defmodule HealthyBackend.Diseases do
  use Ecto.Schema
  import Ecto.Changeset
  alias HealthyBackend.Repo
  import Ecto.Query, only: [from: 2]

  schema "types_diseases" do
    field :title, :string
    field :name, :string
    field :category, :string
    field :data, :string
    field :treatments, :string
    timestamps()
  end

  # CREATE TABLE types_diseases (
  #   id SERIAL PRIMARY KEY,
  #   title VARCHAR(255),
  #   name VARCHAR(255),
  #   data TEXT,
  #   treatments TEXT,
  #   inserted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  #   updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  # );

  def changeset(diseases, attrs, opts \\ []) do
    diseases
    |> cast(attrs, [:title, :name, :category, :data])
    |> validate_required([:title, :name, :category, :data])
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

  def get_posts_by_category(category, page) do
    limit = 10
    offset = (page - 1) * limit

    from(p in HealthyBackend.Diseases,
      where: p.category == ^category,
      limit: ^limit,
      offset: ^offset,
      order_by: [desc: p.inserted_at],
    )
    |> Repo.all()
  end


  def get_diseases_titles do
    from(d in HealthyBackend.Diseases,
      select: d.title
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
