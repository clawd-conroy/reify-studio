defmodule ReifyStudioWeb.Pages.HomeLive do
  use ReifyStudioWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Reify Studio")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="hero min-h-screen">
      <div class="hero-content text-center">
        <div class="max-w-md">
          <h1 class="text-5xl font-bold">Reify Studio</h1>
          <p class="py-6 text-lg opacity-70">
            Your agent workspace. Coming soon.
          </p>
        </div>
      </div>
    </div>
    """
  end
end
