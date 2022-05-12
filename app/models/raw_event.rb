class RawEvent < ApplicationRecord
  validates :data, presence: true
end
