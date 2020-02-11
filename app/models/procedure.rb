################################################################################
#
# Procedure Model
#
# Copyright (c) 2019 The MITRE Corporation.  All rights reserved.
#
################################################################################

class Procedure < Resource

	include ActiveModel::Model

  attr_reader :id, :description, :status, :dateTime, :sortDate, :location

  #-----------------------------------------------------------------------------

  def initialize(fhir_procedure)
    @id 					= fhir_procedure.id
    @sortDate  =   DateTime.parse(fhir_procedure.performedPeriod.start ).to_i 
    @dateTime  =   DateTime.parse(fhir_procedure.performedPeriod.start).strftime("%m/%d/%Y")
    @status       = fhir_procedure.status
    @description = fhir_procedure.code.text
    @location = fhir_procedure.location.display
  end

  #-----------------------------------------------------------------------------


end