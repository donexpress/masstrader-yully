class FbEvent < ApplicationRecord
  validates :data, presence: true
end
