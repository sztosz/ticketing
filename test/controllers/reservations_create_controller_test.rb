# frozen_string_literal: true

require 'test_helper'

class ReservationsCreateControllerTest < ActionDispatch::IntegrationTest
  include ApiGuard::Test::ControllerHelper

  setup do
    @user = users(:user)
    @auth_token = jwt_and_refresh_token(@user, 'user').first
  end

  test 'should return 401 response without Bearer Token' do
    post reservations_url, as: :json
    assert_response :unauthorized
    assert_equal({ 'status' => 'error', 'error' => 'Access token is missing in the request' },
                 JSON.parse(@response.body))
  end

  test 'should return 422 response without ticket ULID and amount being sent' do
    post reservations_url, headers: { "Authorization": "Bearer #{@auth_token}" }, as: :json
    assert_response :unprocessable_entity
    assert_equal({ 'amount' => ['is not a number'], 'ticket' => ['not found'] }, JSON.parse(@response.body))
  end

  test 'should return 422 error when ticket does not exist' do
    post reservations_url, params: { ticket_id: 'GARBAGE', amount: 1 },
                           headers: { "Authorization": "Bearer #{@auth_token}" }, as: :json
    assert_response :unprocessable_entity
    assert_equal({ 'ticket' => ['not found'] }, JSON.parse(@response.body))
  end

  test 'should return 422 error when amount is missing' do
    ticket = tickets(:event_one_even)
    post reservations_url, params: { ticket_id: ticket.id },
                           headers: { "Authorization": "Bearer #{@auth_token}" }, as: :json
    assert_response :unprocessable_entity
    assert_equal({ 'amount' => ['is not a number'] }, JSON.parse(@response.body))
  end

  test 'should return 422 error when amount is odd for even ticket' do
    ticket = tickets(:event_one_even)
    post reservations_url, params: { ticket_id: ticket.id, amount: 5 },
                           headers: { "Authorization": "Bearer #{@auth_token}" }, as: :json
    assert_response :unprocessable_entity
    assert_equal({ 'ticket' => ['amount must be even for chosen option'] }, JSON.parse(@response.body))
  end

  test 'should return 200 error when amount is even for even ticket' do
    ticket = tickets(:event_one_even)
    post reservations_url, params: { ticket_id: ticket.id, amount: 6 },
                           headers: { "Authorization": "Bearer #{@auth_token}" }, as: :json
    assert_response :success
    body = JSON.parse(@response.body)
    assert_equal 6, body['amount']
    assert_equal '6.0', body['total_price']
    assert_equal false, body['paid']
  end

  test 'should return 422 error when not buying all for all_together ticket' do
    ticket = tickets(:event_one_all_together)
    post reservations_url, params: { ticket_id: ticket.id, amount: 5 },
                           headers: { "Authorization": "Bearer #{@auth_token}" }, as: :json
    assert_response :unprocessable_entity
    assert_equal({ 'ticket' => ['all tickets must be reserved for chosen option'] }, JSON.parse(@response.body))
  end

  test 'should return 200 error when buying all for all_together ticket' do
    ticket = tickets(:event_one_all_together)
    post reservations_url, params: { ticket_id: ticket.id, amount: 20 },
                           headers: { "Authorization": "Bearer #{@auth_token}" }, as: :json
    assert_response :success
    body = JSON.parse(@response.body)
    assert_equal 20, body['amount']
    assert_equal '40.0', body['total_price']
    assert_equal false, body['paid']
  end

  test 'should return 422 error when leaving one ticket for avoid_one ticket' do
    ticket = tickets(:event_one_avoid_one)
    post reservations_url, params: { ticket_id: ticket.id, amount: 29 },
                           headers: { "Authorization": "Bearer #{@auth_token}" }, as: :json
    assert_response :unprocessable_entity
    assert_equal({ 'ticket' => ['one ticket can not be left for chosen option'] }, JSON.parse(@response.body))
  end

  test 'should return 200 error when not leaving one ticket for avoid_one ticket' do
    ticket = tickets(:event_one_avoid_one)
    post reservations_url, params: { ticket_id: ticket.id, amount: 28 },
                           headers: { "Authorization": "Bearer #{@auth_token}" }, as: :json
    assert_response :success
    body = JSON.parse(@response.body)
    assert_equal 28, body['amount']
    assert_equal '84.0', body['total_price']
    assert_equal false, body['paid']
  end

  test 'should return 422 error when buying ticket for past event' do
    ticket = tickets(:past_event_ticket)
    post reservations_url, params: { ticket_id: ticket.id, amount: 1 },
                           headers: { "Authorization": "Bearer #{@auth_token}" }, as: :json
    assert_response :unprocessable_entity
    assert_equal({ 'event' => ['cannot buy ticket for past event'] }, JSON.parse(@response.body))
  end
end
