# frozen_string_literal: true

require 'test_helper'

class ReservationsPayControllerTest < ActionDispatch::IntegrationTest
  include ApiGuard::Test::ControllerHelper

  setup do
    @user = users(:user)
    @auth_token = jwt_and_refresh_token(@user, 'user').first
  end

  test 'should return 401 response without Bearer Token' do
    post pay_reservation_url('ANY'), as: :json
    assert_response :unauthorized
    assert_equal({ 'status' => 'error', 'error' => 'Access token is missing in the request' },
                 JSON.parse(@response.body))
  end

  test 'should return 404 response for non existing reservation' do
    post pay_reservation_url('ANY'), headers: { "Authorization": "Bearer #{@auth_token}" }, as: :json

    assert_response :not_found
    assert_equal({ 'error' => 'Reservation not found, they expire after 15 minutes when unpaid' },
                 JSON.parse(@response.body))
  end

  test 'should return 422 response when amount is missing' do
    reservation = reservation(:unpaid_reservation)
    post pay_reservation_url(reservation), headers: { "Authorization": "Bearer #{@auth_token}" }, as: :json
    assert_response :unprocessable_entity
    assert_equal({ 'error' => 'invalid amount' }, JSON.parse(@response.body))
  end

  test 'should return 422 response when amount has wrong value' do
    reservation = reservation(:unpaid_reservation)
    post pay_reservation_url(reservation), params: { amount: 25 },
                                           headers: { "Authorization": "Bearer #{@auth_token}" }, as: :json
    assert_response :unprocessable_entity
    assert_equal({ 'error' => 'invalid amount' }, JSON.parse(@response.body))
  end

  test 'should return 422 response when amount is not numerical' do
    reservation = reservation(:unpaid_reservation)
    post pay_reservation_url(reservation), params: { amount: 'ABC' },
                                           headers: { "Authorization": "Bearer #{@auth_token}" }, as: :json
    assert_response :unprocessable_entity
    assert_equal({ 'error' => 'invalid amount' }, JSON.parse(@response.body))
  end

  test 'should return 422 response when paying for past event' do
    reservation = reservation(:unpaid_reservation_for_past_event)
    post pay_reservation_url(reservation), params: { amount: 1 },
                                           headers: { "Authorization": "Bearer #{@auth_token}" }, as: :json
    assert_response :unprocessable_entity
    assert_equal({ 'event' => ['cannot buy ticket for past event'] }, JSON.parse(@response.body))
  end

  test 'should return 200 response when amount is correct' do
    reservation = reservation(:unpaid_reservation)
    post pay_reservation_url(reservation), params: { amount: 2 },
                                           headers: { "Authorization": "Bearer #{@auth_token}" }, as: :json
    assert_response :success
    assert_equal({ 'message' => 'Payment Successful' }, JSON.parse(@response.body))
  end

  test 'should return XXX when trying to pay for already paid event' do
    reservation = reservation(:paid_reservation)
    post pay_reservation_url(reservation), params: { amount: 2 },
                                           headers: { "Authorization": "Bearer #{@auth_token}" }, as: :json
    assert_response :unprocessable_entity
    assert_equal({ 'error' => 'already paid' }, JSON.parse(@response.body))
  end
end
