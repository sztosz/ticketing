# frozen_string_literal: true

class ReservationEventDateValidator < ActiveModel::Validator
  def validate(reservation)
    @reservation = reservation
    return unless @reservation.ticket

    @event = @reservation.ticket.event
    event_date_errors
  end

  private

  def event_date_errors
    return if @reservation.ticket.event.date >= Time.now.utc

    @reservation.errors[:event] << 'cannot buy ticket for past event'
  end
end
