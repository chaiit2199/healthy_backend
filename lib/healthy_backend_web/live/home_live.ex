defmodule HealthyBackendWeb.HomeLive do
  use HealthyBackendWeb, :live_view
  alias HealthyBackend.Students
  alias HealthyBackend.Repo
  alias GeminiAPI

  def mount(params, _session, socket) do
    changeset = Students.changeset(%Students{}, %{})

    {:ok,
     socket
     |> assign(modal: nil)
     |> assign(form: to_form(changeset))
     |> assign(brightness: 10)}
  end

  def handle_event("on", _params, socket) do
    {:noreply, socket |> assign(brightness: socket.assigns.brightness + 10)}
  end

  def handle_event("down", _params, socket) do
    {:noreply, socket |> assign(brightness: socket.assigns.brightness - 10)}
  end

  def handle_event("open_modal", _params, socket) do
    {:noreply, socket |> assign(modal: "modal")}
  end

  def handle_event("save", %{"students" => student_params}, socket) do
    changeset = Students.changeset(%Students{}, student_params) |> Map.put(:action, :asd)

    case Students.create_student(student_params) do
      {:ok, _student} ->
        {:noreply,
         socket
         |> assign(:form, to_form(changeset))}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_event("search", %{"search" => search}, socket) do
    results = HealthyBackend.Students.search_student(search)
    {:noreply, assign(socket, results: results)}
  end



end
