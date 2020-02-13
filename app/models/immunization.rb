################################################################################
#
# Immnunization Model
#
# Copyright (c) 2019 The MITRE Corporation.  All rights reserved.
#
################################################################################

class Immunization < Resource

	include ActiveModel::Model

  attr_reader :id, :status, :code, :sortDate, :dateTime, :encounter, :location

  #-----------------------------------------------------------------------------

  def initialize(fhir_immunization)
    @id 					= fhir_immunization.id
    @sortDate  =   DateTime.parse(fhir_immunization.occurrenceDateTime).to_i
    @dateTime  =   DateTime.parse(fhir_immunization.occurrenceDateTime).strftime("%m/%d/%Y")
    @status       = fhir_immunization.status
    @location = fhir_immunization.location.display 
    @code = fhir_immunization.vaccineCode.text 
    @encounter = fhir_immunization.encounter.reference 
  end

  #-----------------------------------------------------------------------------


end