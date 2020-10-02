# frozen_string_literal: true

require 'test_helper'

class ReservationsShowControllerTest < ActionDispatch::IntegrationTest
  include ApiGuard::Test::ControllerHelper

  setup do
    @user = users(:user)
    @auth_token = jwt_and_refresh_token(@user, 'user').first
  end

  test 'should return 401 response without Bearer Token' do
    get reservation_url('ANY'), as: :json
    assert_response :unauthorized
    assert_equal JSON.parse(@response.body),
                 { 'status' => 'error', 'error' => 'Access token is missing in the request' }
  end

  test 'should return 200 with Bearer Token' do
    reservation = reservation(:unpaid_reservation)
    get reservation_url(reservation), headers: { "Authorization": "Bearer #{@auth_token}" }, as: :json
    assert_response :success
  end

  test 'should return 200 with details of reservations' do
    reservation = reservation(:unpaid_reservation)
    get reservation_url(reservation), headers: { "Authorization": "Bearer #{@auth_token}" }, as: :json
    assert_response :success
    body = JSON.parse(@response.body)
    assert_equal body['amount'], 2
    assert_equal body['total_price'], '2.0'
    assert_equal body['paid'], false
  end
end

# reservation = reservation(:unpaid_reservation)
# reservation.id
# assert_equal JSON.parse(@response.body),
#                  {'status' => 'error', 'error' => 'Access token is missing in the request'}
