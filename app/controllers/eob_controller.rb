class EobController < ApplicationController
  
  # GET /eobs
  def index
    # read a bundle from a file
    load_bundle
    binding.pry
    @eobs = explanationofbenefits.map { |eob| EOB.new(eob, practitioners, claims, locations, nil) }
    binding.pry 
  end

   # GET /eobs/[id]
  def show
  end
end
