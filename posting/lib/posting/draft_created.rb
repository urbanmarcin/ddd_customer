# frozen_string_literal: true

module Posting
  class DraftCreated < Event

    attribute :title, Types::String
    attribute :title_max_length, Types::Integer.optional
    attribute :description, Types::String.optional
    attribute :uid, Types::String
  end
end
