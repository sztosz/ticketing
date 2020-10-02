# frozen_string_literal: true

require 'test_helper'

class EventsShowControllerTest < ActionDispatch::IntegrationTest
  setup do
    @event_one = events(:event_one)
  end

  test 'should return 200 response' do
    get event_url(@event_one), as: :json
    assert_response :success
  end

  test 'should return json with event' do
    get event_url(@event_one), as: :json
    assert_equal %w[id name date tickets], JSON.parse(@response.body).keys
  end

  test 'should return json with event having tickets' do
    get event_url(@event_one), as: :json
    assert_equal %w[id name option initial_amount price available], JSON.parse(@response.body)['tickets'].first.keys
  end

  test 'should return json with event having proper ticket values' do
    get event_url(@event_one), as: :json
    ticket = JSON.parse(@response.body)['tickets'].filter { |e| e['name'] == 'Even Ticket' }.first

    assert_equal 'Even Ticket', ticket['name']
    assert_equal 'even', ticket['option']
    assert_equal 10, ticket['initial_amount']
    assert_equal '1.0', ticket['price']
  end
end
