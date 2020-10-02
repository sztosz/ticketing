# frozen_string_literal: true

class ReservationsController < ApplicationController
  before_action :authenticate_and_set_user

  def index
    render json: Reservation.where(user_id: current_user.id).all.to_json(only: %i[id ticket_id amount total_price paid])
  end

  def show
    reservation = Reservation.find_by(user_id: current_user.id, id: params[:id])
                             .to_json(only: %i[id ticket_id amount total_price paid])
    if reservation
      render json: reservation
    else
      not_found
    end
  end

  def create
    reservation = Reservation.new(params.permit(:ticket_id, :amount).merge(user: current_user))

    if reservation.valid? && reservation.save
      render json: reservation.to_json(only: %i[id ticket_id amount total_price paid])
    else
      render json: reservation.errors.to_json, status: 422
    end
  end

  def pay
    params.permit(:id, :amount)
    @reservation = Reservation.find_by(id: params['id'], user: current_user)
    return not_found unless @reservation
    return render json: { error: 'already paid' }.to_json, status: 422 if @reservation.paid
    return unless process_amount

    process_payment
  end

  private

  def not_found
    render json: { error: 'Reservation not found, they expire after 15 minutes when unpaid' }.to_json, status: 404
  end

  def invalid_amount
    render json: { error: 'invalid amount' }.to_json, status: 422
  end

  def process_amount
    return invalid_amount && false unless params['amount']

    @amount = BigDecimal(params['amount'])
    return invalid_amount && false unless @amount == @reservation.total_price

    true
  rescue ArgumentError # For when BigDecimal throws it
    invalid_amount && false
  end

  def process_payment
    if @reservation.valid?
      process_valid_reservation
    else
      render json: @reservation.errors.to_json, status: 422
    end
  rescue Adapters::Payments::Gateway::CardError => e
    render json: { error: e }.to_json, status: 402
  rescue Adapters::Payments::Gateway::PaymentError => e
    render json: { error: e }.to_json, status: 402
  end

  def process_valid_reservation
    Adapters::Payments::Gateway.charge(amount: @amount, token: :ok)
    @reservation.paid = true
    @reservation.save!
    render json: { message: 'Payment Successful' }.to_json
  end
end
