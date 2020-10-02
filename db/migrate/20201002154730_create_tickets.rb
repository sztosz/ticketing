# frozen_string_literal: true

class CreateTickets < ActiveRecord::Migration[6.0]
  def change
    create_table :tickets, id: false do |t|
      t.binary :id, limit: 16, primary_key: true

      t.string :name, null: false
      t.string :option, null: false
      t.integer :initial_amount, null: false
      t.decimal :price, null: false

      t.belongs_to :event, null: false, foreign_key: true, type: :binary

      t.timestamps
    end
    add_index :tickets, %i[event_id name], unique: true
  end
end
