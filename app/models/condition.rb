################################################################################
#
# Condition Model
#
# Copyright (c) 2019 The MITRE Corporation.  All rights reserved.
#
################################################################################

class Condition < Resource

	include ActiveModel::Model

  attr_reader :id, :description, :dateTime,  :sortDate, :category, :encounter,
    :clinicalstatus, :category, :encounter

  #-----------------------------------------------------------------------------

  def initialize(fhir_condition)
    @id 					= fhir_condition.id
    @sortDate  =   DateTime.parse(fhir_condition.recordedDate).to_i
    @dateTime =   DateTime.parse(fhir_condition.recordedDate).strftime("%m/%d/%Y")
    @description = getCodeableConceptDisplay(fhir_condition.code)
    @encounter = fhir_condition.encounter.reference 
    @category = getCodeableConceptDisplay(fhir_condition.category[0])
    @clinicalstatus = fhir_condition.clinicalStatus.coding.map(&:code).join(",")
  end

  #-----------------------------------------------------------------------------
  def getCodeableConceptDisplay (codeableconcept)
      codeableconcept.coding.map(&:display).join(",")
  end 

end
