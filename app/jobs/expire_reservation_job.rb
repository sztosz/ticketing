# frozen_string_literal: true

class ExpireReservationJob < ApplicationJob
  queue_as :default

  perform_every '1 minute'

  def perform(*_args)
    Reservation.where(paid: false).where('created_at <= ?', Time.now - 15.minutes).delete_all
  end
end
