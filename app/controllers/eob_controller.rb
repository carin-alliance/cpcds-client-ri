class EobController < ApplicationController
  # GET /eobs 
  def index # read a bundle from a file 
    load_bundle 
    @eobs = explanationofbenefits.map { |eob| EOB.new(eob, practitioners, claims, locations, nil) } 
    binding.pry 
  end
  # GET /eobs/[id] 
  def show 
    load_bundle 
    @eobs = explanationofbenefits.map { |eob| EOB.new(eob, practitioners, claims, locations, nil) } 
    binding.pry # How do I get the id from the URL? id = 0; binding.pry reference = id.gsub("urn:uuid:", "") @eob = explanationofbenefits.select{|p| p.id==reference}[0] binding.pry 
  end
end
