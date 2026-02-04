defmodule ReifyWeb.App do
  @moduledoc """
  Embeds the root HTML layout template.
  """
  use ReifyWeb, :html

  embed_templates "*.html"
end
