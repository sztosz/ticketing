# frozen_string_literal: true

require 'test_helper'

class EventsIndexControllerTest < ActionDispatch::IntegrationTest
  setup do
    @event_one = events(:event_one)
    @event_two = events(:event_two)
  end

  test 'should return 200 response' do
    get events_url, as: :json
    assert_response :success
  end

  test 'should return json with events' do
    get events_url, as: :json
    assert_equal %w[id name date tickets], JSON.parse(@response.body).first.keys
  end

  test 'should return json with events having tickets' do
    get events_url, as: :json
    ticket = JSON.parse(@response.body).filter { |e| e['name'] == 'Event 1' }.first['tickets'].first
    assert_equal %w[id name option initial_amount price], ticket.keys
  end

  test 'should return json with events having proper name' do
    get events_url, as: :json
    body = JSON.parse(@response.body)
    assert(body.any?) { |e| e['name'] == 'Event 1' }
    assert(body.any?) { |e| e['name'] == 'Event 2' }
  end

  test 'should return json with event having proper ticket values' do
    get events_url, as: :json
    ticket = JSON.parse(@response.body)
                 .filter { |e| e['name'] == 'Event 1' }.first['tickets']
                 .filter { |e| e['name'] == 'Even Ticket' }.first

    assert_equal 'even', ticket['option']
    assert_equal 10, ticket['initial_amount']
    assert_equal '1.0', ticket['price']
  end
end
