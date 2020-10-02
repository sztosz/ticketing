# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# ['even', 'all together', 'avoid one']
case Ticket::VALID_TICKET_OPTIONS
in [even, all_together, avoid_one]
  old_event = Event.create(name: 'Old Event', date: Time.utc(2010, 1, 1, 1, 1))
  Ticket.create(name: 'normal', event: old_event, option: even, initial_amount: 100, price: 15.0)
  Ticket.create(name: 'vip lounge', event: old_event, option: all_together, initial_amount: 20, price: 30.0)
  Ticket.create(name: 'first row', event: old_event, option: avoid_one, initial_amount: 20, price: 25)

  future_event1 = Event.create(name: 'Future Event 1', date: Time.utc(2021, 1, 1, 1, 1))
  Ticket.create(name: 'normal', event: future_event1, option: even, initial_amount: 100, price: 7.0)
  Ticket.create(name: 'obscured_sector', event: future_event1, option: all_together, initial_amount: 20, price: 2.5)
  Ticket.create(name: 'premium', event: future_event1, option: avoid_one, initial_amount: 20, price: 25)

  future_event2 = Event.create(name: 'Future Event 2', date: Time.utc(2021, 1, 2, 1, 1))
  Ticket.create(name: 'normal', event: future_event2, option: even, initial_amount: 500, price: 10.0)

  future_event3 = Event.create(name: 'Future Event 3', date: Time.utc(2021, 1, 2, 1, 1))
  Ticket.create(name: 'private_party', event: future_event3, option: all_together, initial_amount: 15, price: 10.0)

  future_event3 = Event.create(name: 'Future Event 4', date: Time.utc(2021, 1, 2, 1, 1))
  Ticket.create(name: 'normal', event: future_event3, option: avoid_one, initial_amount: 15, price: 10.0)
else
  raise 'Seeds are not update to reflect changes in Ticket.VALID_TICKET_OPTIONS'
end
