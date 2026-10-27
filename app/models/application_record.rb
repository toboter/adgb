class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # Local sharer / shareable macros (replaced the shareable_models gem).
  extend Sharing::ClassMethods
end
