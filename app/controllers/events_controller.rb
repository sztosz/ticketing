# frozen_string_literal: true

class EventsController < ApplicationController
  def index
    render json: Event
      .all
      .as_json(only: %i[id name date], include: { tickets: { only: %i[id name option initial_amount price] } })
  end

  def show
    render json: Event.find(params[:id])
                      .as_json(only: %i[id name date],
                               include: { tickets: { only: %i[id name option initial_amount price],
                                                     methods: :available, } })
  end
end
