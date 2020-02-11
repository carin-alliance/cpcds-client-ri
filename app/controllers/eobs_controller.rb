class EobsController < ApplicationController
  # GET /eobs 
  def index # read a bundle from a file 
    load_bundle 
    @eobs = explanationofbenefits.map { |eob| EOB.new(eob, practitioners, claims, locations, observations, nil) } 
    #binding.pry 
  end
  # GET /eobs/[id] 
  def show 
    load_bundle 
    @eobs = explanationofbenefits.map { |eob| EOB.new(eob, practitioners, claims, locations, observations,nil) } 
    #binding.pry # How do I get the id from the URL? id = 0; binding.pry reference = id.gsub("u rn:uuid:", "") 
    reference = params[:id]
    @eob = @eobs.select{|p| p.id = reference}[0] 
    binding.pry 
  end
end
