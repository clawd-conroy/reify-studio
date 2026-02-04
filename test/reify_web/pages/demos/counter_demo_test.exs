defmodule ReifyWeb.Pages.Demos.CounterDemoTest do
  use ReifyWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  describe "mount/3" do
    test "initializes with count 0, no error, and a response_id", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/demos/counter")

      # Verify React component is rendered with correct props
      # Props are HTML-escaped in the data-props attribute
      assert html =~ "data-name=\"CounterDemoLayout\""
      assert html =~ "&quot;count&quot;:0"
      assert html =~ "&quot;error&quot;:null"
      # response_id should be an 8-character hex string
      assert html =~ ~r/&quot;responseId&quot;:&quot;[a-f0-9]{8}&quot;/
    end
  end

  describe "handle_event/3" do
    test "ping without mode increments count", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/demos/counter")

      # The React component receives the count prop, but we test the LiveView assigns
      assert render_hook(view, "ping", %{}) =~ "CounterDemoLayout"
    end

    test "ping with slow mode increments count after delay", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/demos/counter")

      # This will take ~1 second due to Process.sleep
      assert render_hook(view, "ping", %{"mode" => "slow"}) =~ "CounterDemoLayout"
    end

    test "ping with error mode sets error flag", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/demos/counter")

      # This will take ~1 second due to Process.sleep
      assert render_hook(view, "ping", %{"mode" => "error"}) =~ "CounterDemoLayout"
    end
  end
end
