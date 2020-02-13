################################################################################
#
# Medication Model
#
# Copyright (c) 2019 The MITRE Corporation.  All rights reserved.
#
################################################################################

class Medication < Resource

	include ActiveModel::Model

  attr_reader :id, :description, :status, :authoredOnDate, :requester, :sortDate

  #-----------------------------------------------------------------------------

  def initialize(fhir_medicationrequest)
    @id 					= fhir_medicationrequest.id
    @sortDate  =   DateTime.parse(fhir_medicationrequest.authoredOn).to_i
    @authoredOnDate  =   DateTime.parse(fhir_medicationrequest.authoredOn).strftime("%m/%d/%Y")
    @status       = fhir_medicationrequest.status
    @description = fhir_medicationrequest.medicationCodeableConcept.coding.map(&:display).join("")
    @requester = fhir_medicationrequest.requester.display
  end

  #-----------------------------------------------------------------------------


end
