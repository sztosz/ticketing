# frozen_string_literal: true

class Reservation < ApplicationRecord
  belongs_to :ticket
  belongs_to :user

  validates :ticket, presence: true
  validates :user, presence: true
  validates :amount, numericality: { only_integer: true }
  validates_with ReservationEventDateValidator
  validates_with ReservationTicketValidator

  before_save :calculate_price

  def calculate_price
    self.total_price = ticket.price * amount
  end
end
