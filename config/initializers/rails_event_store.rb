require 'rails_event_store'
require 'aggregate_root'
require 'arkency/command_bus'

Rails.configuration.to_prepare do
  Rails.configuration.event_store = RailsEventStore::Client.new
  Rails.configuration.command_bus = Arkency::CommandBus.new

  AggregateRoot.configure do |config|
    config.default_event_store = Rails.configuration.event_store
  end

  # Subscribe event handlers below
  Rails.configuration.event_store.tap do |store|
    store.subscribe(Posts::OnDraftCreated, to: [Posting::DraftCreated])
    store.subscribe(Posts::OnPostRemoved, to: [Posting::PostRemoved])
    store.subscribe(Posts::OnPostPublished, to: [Posting::PostPublished])
    store.subscribe(Posts::CaptureSagaState, to: [Approving::PostApproved])

  #   store.subscribe(->(event) { SendOrderConfirmation.new.call(event) }, to: [OrderSubmitted])
  #   store.subscribe_to_all_events(->(event) { Rails.logger.info(event.type) })
  end

  # Register command handlers below
  Rails.configuration.command_bus.tap do |bus|
    bus.register(Posting::CreateDraft, ->(cmd) { Posting::OnCreateDraft.new.call(cmd) })
    bus.register(Posting::UpdateText, ->(cmd) { Posting::OnUpdateText.new.call(cmd) })
    bus.register(Posting::RemovePost, ->(cmd) { Posting::OnRemovePost.new.call(cmd) })
    bus.register(Posting::PublishPost, ->(cmd) { Posting::OnPublishPost.new.call(cmd) })
    bus.register(Approving::ApprovePost, ->(cmd) { Approving::OnApprovePost.new.call(cmd) })
    bus.register(Posting::MarkAsApproved, ->(cmd) { Posting::OnMarkAsApproved.new.call(cmd) })

    #bus.register(PrintInvoice, Invoicing::OnPrint.new)
    #bus.register(SubmitOrder,  ->(cmd) { Ordering::OnSubmitOrder.new.call(cmd) })
  end
end
