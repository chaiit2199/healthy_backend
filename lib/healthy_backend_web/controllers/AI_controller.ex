defmodule HealthyBackendWeb.AIController do
  use HealthyBackendWeb, :controller
  alias HealthyBackend.GeminiAPI
  alias HealthyBackend.Diseases
  require Logger

  def index(conn, %{"params" => prompt}) do
    case Diseases.search_diseases(prompt) do
      nil ->
        json(conn, %{response: %{name: nil, data: nil, category: nil, updated_at: nil}})

      %HealthyBackend.Diseases{name: name, data: data, category: category, updated_at: updated_at} ->
        json(conn, %{response: %{name: name, data: data, category: category, updated_at: updated_at}})
    end
  end

  def get(conn, _params) do
    names = Diseases.get_diseases_names()
    json(conn, names)
  end

  def get_recent_diseases(conn, _params) do
    diseases =
      Diseases.get_recent_diseases(8)
      |> Enum.map(&format_disease/1)

    json(conn, diseases)
  end

  def get_category_posts(conn, %{"category" => category, "page" => page}) do
    page = String.to_integer(page)

    diseases = Diseases.get_posts_by_category(category, page)
    |> Enum.map(&format_get_posts_by_category/1)

    json(conn, diseases)
  end

  def get_category_posts(conn, %{"category" => category}) do
    page = 1

    diseases = Diseases.get_posts_by_category(CommonComponents.batch_string(category), page)
    |> Enum.map(&format_get_posts_by_category/1)

    json(conn, diseases)
  end

  def get_posts_today(conn, _) do
    diseases =
      Diseases.get_posts_today()
      |> Enum.map(&format_disease/1)

    json(conn, diseases)
  end


  defp format_disease(disease) do
    disease
    |> Map.from_struct()
    |> Map.drop([:__meta__, :__id__, :treatments, :inserted_at])
    |> Map.update!(:data, &format_data/1)
    |> Map.update!(:updated_at, &format_date/1)
    |> format_disease_desc()
  end

  defp format_disease_desc(%{data: %{"Giới thiệu" => content}} = map) do
    %{map | data: content}
  end

  defp format_disease_desc(map), do: map

  defp format_get_posts_by_category(disease) do
    disease
    |> Map.from_struct()
    |> Map.drop([:__meta__, :__id__, :treatments, :inserted_at])
    |> Map.update!(:data, &format_data/1)
    |> Map.update!(:updated_at, &format_date/1)
    |> format_disease_desc()
  end

  defp format_data(data) do
    data
    |> String.replace("\n", "")  # Remove all newline characters
    |> String.replace(~r/\s{2,}/, " ")  # Replace multiple spaces with a single space
    |> Jason.decode!()  # Decode the cleaned string
    |> List.first()  # Assuming you want to get the first element
  end

  defp format_date(datetime) do
    datetime
    |> NaiveDateTime.to_date()
    |> Calendar.strftime("%d/%m/%Y")
  end
end
