module Import
  class Header < ApplicationRecord
    # t.integer  :sheet_id, index: true
    # t.string   :name
    # t.string   :attribute_mapping

    belongs_to :sheet, counter_cache: true

    validates :attribute_mapping, inclusion: { in: Proc.new { |a| a.model_mapping_attributes },
      message: "to '%{value}' is not a valid model attribute" }, allow_blank: true

    def model_mapping_attributes
      if sheet.model_mapping.present? 
        sheet.model_mapping.classify.constantize.col_attr
      else
        []
      end
    end
  end
end