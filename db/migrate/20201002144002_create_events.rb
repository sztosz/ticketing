# frozen_string_literal: true

class CreateEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :events, id: false do |t|
      t.binary :id, limit: 16, primary_key: true

      t.string :name
      t.datetime :date

      t.timestamps
    end
  end
end
