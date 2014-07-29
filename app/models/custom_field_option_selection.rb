class CustomFieldOptionSelection < ActiveRecord::Base
  belongs_to :custom_field_value, dependent: :destroy
  belongs_to :custom_field_option
end
