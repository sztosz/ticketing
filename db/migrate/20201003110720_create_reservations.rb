# frozen_string_literal: true

class CreateReservations < ActiveRecord::Migration[6.0]
  def change
    create_table :reservations, id: false do |t|
      t.binary :id, limit: 16, primary_key: true

      t.belongs_to :user, null: false, foreign_key: true, type: :binary
      t.belongs_to :ticket, null: false, foreign_key: true, type: :binary

      t.integer :amount, null: false
      t.decimal :total_price, null: false
      t.boolean :paid, default: false

      t.timestamps
    end
  end
end
