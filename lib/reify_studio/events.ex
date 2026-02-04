defmodule ReifyStudio.Events do
  @moduledoc """
  Helper functions for formatting events sent between LiveView and React.

  Provides standardized error formatting for Ash changesets and errors,
  following the event-types.md specification.
  """

  @doc """
  Formats an Ash changeset or error into a standard error event payload.

  Returns a map with:
  - source: which event caused the error
  - code: machine-readable error code
  - message: human-readable message
  - field: (optional) which field failed
  - details: (optional) additional context including all errors

  ## Examples

      iex> ReifyStudio.Events.format_error("create_todo", changeset)
      %{source: "create_todo", code: "validation_failed", message: "can't be blank", field: "title", details: %{...}}
  """
  def format_error(source, %Ash.Changeset{} = changeset) do
    errors = format_changeset_errors(changeset)
    {field, messages} = first_error(errors)

    %{
      source: source,
      code: "validation_failed",
      message: List.first(messages) || "Validation failed",
      field: field_to_string(field),
      details: %{all_errors: errors}
    }
  end

  def format_error(source, %Ash.Error.Invalid{} = error) do
    errors = format_ash_error(error)
    {field, messages} = first_error(errors)

    %{
      source: source,
      code: "validation_failed",
      message: List.first(messages) || "Validation failed",
      field: field_to_string(field),
      details: %{all_errors: errors}
    }
  end

  def format_error(source, message) when is_binary(message) do
    %{
      source: source,
      code: "error",
      message: message
    }
  end

  def format_error(source, %Ash.Error.Framework{errors: errors}) do
    message =
      errors
      |> Enum.map(&Exception.message/1)
      |> Enum.join("; ")

    %{
      source: source,
      code: "framework_error",
      message: message
    }
  end

  def format_error(source, _unknown) do
    %{
      source: source,
      code: "unknown_error",
      message: "An unexpected error occurred"
    }
  end

  # --- Private Helpers ---

  defp format_changeset_errors(%Ash.Changeset{errors: errors}) do
    Enum.reduce(errors, %{}, fn error, acc ->
      field = error.field || :base
      message = interpolate_message(error)
      Map.update(acc, field, [message], &[message | &1])
    end)
  end

  defp format_ash_error(%Ash.Error.Invalid{errors: errors}) do
    Enum.reduce(errors, %{}, fn error, acc ->
      field = get_error_field(error)
      message = interpolate_message(error)
      Map.update(acc, field, [message], &[message | &1])
    end)
  end

  defp get_error_field(%{fields: [field | _]}), do: field
  defp get_error_field(%{field: field}) when not is_nil(field), do: field
  defp get_error_field(_), do: :base

  defp interpolate_message(%{message: message, vars: vars}) do
    Enum.reduce(vars, message, fn {key, value}, msg ->
      String.replace(msg, "%{#{key}}", stringify(value))
    end)
  end

  defp interpolate_message(%{message: message}), do: message

  defp interpolate_message(error) when is_exception(error) do
    Exception.message(error)
  end

  defp stringify(value) when is_list(value), do: inspect(value)
  defp stringify(value), do: to_string(value)

  defp first_error(errors) when map_size(errors) == 0, do: {:base, []}
  defp first_error(errors), do: Enum.at(errors, 0)

  defp field_to_string(:base), do: nil
  defp field_to_string(field), do: to_string(field)
end
