

class EobsController < ApplicationController
  before_action :establish_session_handler, only: [ :index, :show ]
  # GET /eobs 
  def index # read a bundle from a file 
    pid = session[:patient_id]
    binding.pry if pid == nil 
    @fhir_explanationofbenefits = @fhir_explanationofbenefits || load_patient_resources(FHIR::ExplanationOfBenefit, nil, :patient, pid, :created )
    explanationofbenefits = fhir_explanationofbenefits.map { |eob| EOB.new(eob, @resources, @client) }.sort_by { |a|  -a.sortDate }
    @eobs = explanationofbenefits
    @start_date = start_date
    @end_date = end_date 
  end
  # GET /eobs/[id] 
  def show 
    pid = session[:patient_id]
    id = params[:id]
    binding.pry if pid == nil 
    # binding.pry 
    if @eobs
      @eob = @eobs.select{|p| p.id == id}[0] 
    elsif @fhir_explanationofbenefits
      fhir_explanationofbenefit = @fhir_explanationofbenefits.select{|p| p.id == id}[0]
      @eob = EOB.new(fhir_explanationofbenefit, @resources, @client)
    else
      fhir_explanationofbenefit = get_fhir_resources(@client, FHIR::ExplanationOfBenefit, id)[0]
      @eob = EOB.new(fhir_explanationofbenefit, @resources, @client)
    end
    # binding.pry 
  end

end
