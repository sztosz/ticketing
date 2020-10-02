# frozen_string_literal: true

class ReservationTicketValidator < ActiveModel::Validator
  def validate(reservation)
    @reservation = reservation
    ticket_errors
    return unless @reservation.ticket
    return unless @reservation.amount

    @available = @reservation.ticket.available
    amount_errors
    option_errors
  end

  private

  def ticket_errors
    return if @reservation.ticket

    @reservation.errors.delete(:ticket)
    @reservation.errors.add(:ticket, :not_found)
  end

  def amount_errors
    return if @available >= @reservation.amount

    @reservation.errors[:ticket] << 'not possible to purchase more tickets than available'
  end

  def option_errors
    case @reservation.ticket.option
    when 'even'
      even
    when 'all together'
      all_together
    when 'avoid one'
      avoid_one
    end
  end

  def even
    @reservation.errors[:ticket] << 'amount must be even for chosen option' unless @reservation.amount.even?
  end

  def all_together
    return if @reservation.ticket.initial_amount == @reservation.amount

    @reservation.errors[:ticket] << 'all tickets must be reserved for chosen option'
  end

  def avoid_one
    return unless @available - @reservation.amount == 1

    @reservation.errors[:ticket] << 'one ticket can not be left for chosen option'
  end
end
