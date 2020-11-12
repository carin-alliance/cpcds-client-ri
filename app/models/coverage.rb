################################################################################
#
# Coverage Model
#
# Copyright (c) 2019 The MITRE Corporation.  All rights reserved.
#
################################################################################

class Coverage < Resource

	include ActiveModel::Model

  attr_reader :id, :identifiers, :payors, :period, :relationship, :subscriberId, :type 

  #-----------------------------------------------------------------------------

  def initialize(fhir_coverage)
    @id 	= fhir_coverage.id
    @identifiers = fhir_coverage.identifier
    @payors = fhir_coverage.payor
    @period = fhir_coverage.period
    @relationship = fhir_coverage.relationship
    @subscriberId = fhir_coverage.subscriberId
    @type = fhir_coverage.type 
  end


end