

class EobsController < ApplicationController
  before_action :establish_session_handler, only: [ :index, :show ]
  # GET /eobs 
  def index # read a bundle from a file 
    load_patient_specific_data_from_server
    @eobs = fhir_explanationofbenefits.map { |eob| EOB.new(eob, @resources, @client) }.sort_by { |a|  -a.sortDate }
    #binding.pry 
  end
  # GET /eobs/[id] 
  def show 
    binding.pry
    load_patient_specific_data_from_server
    @eobs = fhir_explanationofbenefits.map { |eob| EOB.new(eob, @resources,@client) }
    #binding.pry # How do I get the id from the URL? id = 0; binding.pry reference = id.gsub("u rn:uuid:", "") 
    reference = params[:id]
    binding.pry 
    @eob = @eobs.select{|p| p.id == reference}[0] 
  end
end
