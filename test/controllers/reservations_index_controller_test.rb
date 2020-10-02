# frozen_string_literal: true

require 'test_helper'

class ReservationsIndexControllerTest < ActionDispatch::IntegrationTest
  include ApiGuard::Test::ControllerHelper

  setup do
    @user = users(:user)
    @auth_token = jwt_and_refresh_token(@user, 'user').first
  end

  test 'should return 401 response without Bearer Token' do
    get reservations_url, as: :json
    assert_response :unauthorized
    assert_equal({ 'status' => 'error', 'error' => 'Access token is missing in the request' },
                 JSON.parse(@response.body))
  end

  test 'should return 200 response with Bearer Token' do
    get reservations_url, headers: { "Authorization": "Bearer #{@auth_token}" }, as: :json
    assert_response :success
  end

  test 'should return 200 with details of reservations' do
    get reservations_url, headers: { "Authorization": "Bearer #{@auth_token}" }, as: :json
    reservation = JSON.parse(@response.body).first
    assert reservation.key?('id')
    assert reservation.key?('ticket_id')
    assert reservation.key?('amount')
    assert reservation.key?('total_price')
    assert reservation.key?('paid')
  end
end
