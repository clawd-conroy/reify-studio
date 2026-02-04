defmodule ReifyWeb.Pages.Demos.DemosLive do
  @moduledoc """
  Landing page for Reify demos.

  Displays available demos as navigable cards with descriptions.
  Pure HEEx - no React needed for this static page.
  """
  use ReifyWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Demos")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-slate-900 via-slate-800 to-slate-900">
      <div class="max-w-5xl mx-auto px-6 py-12">
        <!-- Header -->
        <header class="text-center mb-16">
          <div class="flex justify-center mb-6">
            <img src={~p"/images/pearl-stack-logo.png"} alt="PeARL Stack" class="h-24 w-auto" />
          </div>
          <h1 class="text-4xl font-bold text-white mb-4">
            Reify Demos
          </h1>
          <p class="text-xl text-slate-300 max-w-2xl mx-auto mb-2">
            Interactive examples showcasing the
            <span class="font-semibold text-emerald-400">PeARL Stack</span>
          </p>
          <p class="text-xl text-slate-300 max-w-2xl mx-auto mb-4">
            <span class="font-semibold text-emerald-400">P</span>hoenix · <span class="font-semibold text-emerald-400">e</span>vents · <span class="font-semibold text-emerald-400">A</span>sh · <span class="font-semibold text-emerald-400">R</span>eact · <span class="font-semibold text-emerald-400">L</span>iveView
          </p>
          <p class="text-slate-400 max-w-xl mx-auto">
            The beginner-friendly, vibe-proof stack
          </p>
          <a
            href="https://conroywhitney.github.io/PeARL-stack/"
            target="_blank"
            rel="noopener noreferrer"
            class="inline-flex items-center gap-2 mt-6 text-emerald-400 hover:text-emerald-300 transition-colors"
          >
            Learn more about PeARL Stack
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"
              />
            </svg>
          </a>
        </header>
        
    <!-- Demo Cards -->
        <div class="grid md:grid-cols-2 gap-8 justify-center">
          <!-- Counter Demo Card -->
          <.link navigate={~p"/demos/counter"} class="group block">
            <div class="bg-slate-800/50 backdrop-blur border border-slate-700 rounded-2xl overflow-hidden hover:border-emerald-500/50 transition-all duration-300 hover:shadow-lg hover:shadow-emerald-500/10 h-[400px] flex flex-col">
              <!-- Icon Header -->
              <div class="h-40 bg-gradient-to-br from-slate-700 to-slate-800 flex items-center justify-center border-b border-slate-700">
                <div class="text-6xl">
                  <svg
                    class="w-20 h-20 text-emerald-400 group-hover:scale-110 transition-transform duration-300"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="1.5"
                      d="M12 6v6l4 2m6-2a10 10 0 11-20 0 10 10 0 0120 0z"
                    />
                  </svg>
                </div>
              </div>
              
    <!-- Card Content -->
              <div class="p-6 flex-1 flex flex-col">
                <h2 class="text-2xl font-bold text-white mb-3 group-hover:text-emerald-400 transition-colors">
                  Counter Demo
                </h2>
                <p class="text-slate-300 mb-4 flex-1">
                  Explore the difference between SSR, LiveReact, local state, and optimistic updates. See how
                  <span class="text-emerald-400">pushEvent</span>
                  flows from React to LiveView.
                </p>
                <div class="flex flex-wrap gap-2">
                  <span class="px-2 py-1 bg-slate-700/50 rounded text-xs text-slate-400">SSR</span>
                  <span class="px-2 py-1 bg-slate-700/50 rounded text-xs text-slate-400">
                    LiveReact
                  </span>
                  <span class="px-2 py-1 bg-slate-700/50 rounded text-xs text-slate-400">
                    Optimistic UI
                  </span>
                </div>
              </div>
            </div>
          </.link>
          
    <!-- Todos Demo Card -->
          <.link navigate={~p"/demos/todos"} class="group block">
            <div class="bg-slate-800/50 backdrop-blur border border-slate-700 rounded-2xl overflow-hidden hover:border-amber-500/50 transition-all duration-300 hover:shadow-lg hover:shadow-amber-500/10 h-[400px] flex flex-col">
              <!-- Icon Header -->
              <div class="h-40 bg-gradient-to-br from-slate-700 to-slate-800 flex items-center justify-center border-b border-slate-700">
                <div class="text-6xl">
                  <svg
                    class="w-20 h-20 text-amber-400 group-hover:scale-110 transition-transform duration-300"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="1.5"
                      d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4"
                    />
                  </svg>
                </div>
              </div>
              
    <!-- Card Content -->
              <div class="p-6 flex-1 flex flex-col">
                <h2 class="text-2xl font-bold text-white mb-3 group-hover:text-amber-400 transition-colors">
                  Todos Demo
                </h2>
                <p class="text-slate-300 mb-4 flex-1">
                  Full CRUD with <span class="text-amber-400">Ash Resources</span>
                  and the Event Commands pattern. Dual validation with Zod (client) and Ash (server).
                </p>
                <div class="flex flex-wrap gap-2">
                  <span class="px-2 py-1 bg-slate-700/50 rounded text-xs text-slate-400">Ash</span>
                  <span class="px-2 py-1 bg-slate-700/50 rounded text-xs text-slate-400">
                    Event Commands
                  </span>
                  <span class="px-2 py-1 bg-slate-700/50 rounded text-xs text-slate-400">
                    Dual Validation
                  </span>
                </div>
              </div>
            </div>
          </.link>
        </div>
        
    <!-- Footer -->
        <footer class="mt-16 text-center text-slate-500 text-sm">
          <p>
            Built with
            <a
              href="https://github.com/mrdotb/live_react"
              target="_blank"
              rel="noopener noreferrer"
              class="text-slate-400 hover:text-white transition-colors"
            >
              live_react
            </a>
            ·
            <a
              href="https://ash-hq.org"
              target="_blank"
              rel="noopener noreferrer"
              class="text-slate-400 hover:text-white transition-colors"
            >
              Ash Framework
            </a>
            ·
            <a
              href="https://phoenixframework.org"
              target="_blank"
              rel="noopener noreferrer"
              class="text-slate-400 hover:text-white transition-colors"
            >
              Phoenix
            </a>
          </p>
        </footer>
      </div>
    </div>
    """
  end
end
