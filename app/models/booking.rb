# == Schema Information
#
# Table name: bookings
#
#  id                      :integer          not null, primary key
#  listing_conversation_id :integer
#  start_on                :date
#  end_on                  :date
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

class Booking < ActiveRecord::Base

  belongs_to :conversation

  attr_accessible :conversation_id, :end_on, :start_on

  validates :start_on, :end_on, presence: true
  validates_date :start_on, on_or_after: :today
  validates_date :end_on, on_or_after: :start_on

  def duration
    (end_on - start_on).to_i + 1
  end

end
