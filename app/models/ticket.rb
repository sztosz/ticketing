# frozen_string_literal: true

class Ticket < ApplicationRecord
  VALID_TICKET_OPTIONS = ['even', 'all together', 'avoid one'].freeze

  belongs_to :event
  has_many :Reservations

  validates :option, inclusion: { in: VALID_TICKET_OPTIONS }
  validates :event, presence: true

  def available
    initial_amount - Reservation.where(ticket_id: id).sum(:amount)
  end
end
