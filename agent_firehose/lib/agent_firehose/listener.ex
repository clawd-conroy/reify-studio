defmodule AgentFirehose.Listener do
  @moduledoc """
  Subscribes to the AT Protocol Jetstream firehose and listens for
  social.agent.* collection events — our BlueClaw/Chao lexicons.

  Also watches our own DID for any record activity.
  """

  use Drinkup.Jetstream,
    name: :agent_listener,
    wanted_collections: [
      "social.agent.actor.profile",
      "social.agent.capability.card",
      "social.agent.delegation.grant",
      "social.agent.delegation.revocation",
      "social.agent.draft.post",
      "social.agent.feed.post",
      "social.agent.graph.follow",
      "social.agent.operator.declaration",
      "social.agent.reputation.attestation",
      "social.agent.task.request",
      "social.agent.task.result",
      "com.atproto.lexicon.schema"
    ],
    wanted_dids: [
      "did:plc:ntmjmntkqjybphe7zb6ktixf"
    ]

  require Logger

  @impl true
  def handle_event(%Drinkup.Jetstream.Event.Commit{} = event) do
    Logger.info("""
    🔥 Agent event detected!
      DID: #{event.did}
      Op:  #{event.operation}
      Collection: #{event.collection}
      Record key: #{event.rkey}
    """)

    if event.operation == :create and is_map(event.record) do
      Logger.info("  Record: #{inspect(event.record, pretty: true, limit: 500)}")
    end

    :ok
  end

  def handle_event(%Drinkup.Jetstream.Event.Identity{} = event) do
    Logger.info("🆔 Identity event: #{event.did}")
    :ok
  end

  def handle_event(event) do
    Logger.debug("Other event: #{inspect(event, limit: 200)}")
    :ok
  end
end
