

class EobsController < ApplicationController
  before_action :establish_session_handler, only: [ :index, :show ]
  # GET /eobs 
  def index # read a bundle from a file 
    load_patient_specific_data_from_server
    @eobs = fhir_explanationofbenefits.map { |eob| EOB.new(eob, @resources, @client) }.sort_by { |a|  -a.sortDate }
    @start_date = start_date
    @end_date = end_date 
  end
  # GET /eobs/[id] 
  def show 
    load_patient_specific_data_from_server
    @eobs = fhir_explanationofbenefits.map { |eob| EOB.new(eob, @resources,@client) }
    reference = params[:id]
    @eob = @eobs.select{|p| p.id == reference}[0] 
  end
end
