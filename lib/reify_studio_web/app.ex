defmodule ReifyStudioWeb.App do
  @moduledoc """
  Embeds the root HTML layout template.
  """
  use ReifyStudioWeb, :html

  embed_templates "*.html"
end
