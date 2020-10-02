# frozen_string_literal: true

class CreatePerformEvery < ActiveRecord::Migration[6.0]
  # rubocop:disable Metrics/MethodLength
  def change
    create_table :perform_every do |t|
      t.string :job_name
      t.string :typ # every|at
      t.string :value
      t.string :history, array: true
      t.datetime :last_performed_at
      t.datetime :perform_at
      t.boolean :deprecated, null: false, default: false
    end

    add_index :perform_every, %i[job_name typ value], unique: true, name: 'perform_every_unique_job'
    add_index :perform_every, :deprecated
  end
  # rubocop:enable Metrics/MethodLength
end
