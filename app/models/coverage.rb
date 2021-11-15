################################################################################
#
# Coverage Model
#
# Copyright (c) 2019 The MITRE Corporation.  All rights reserved.
#
################################################################################

class Coverage < Resource

	include ActiveModel::Model

  attr_reader :id, :identifiers, :payors, :period_start, :period_end, :relationship, :subscriberId, :type, :classes 

  #-----------------------------------------------------------------------------

  def initialize(fhir_coverage, organizations)
    @id 	= fhir_coverage.id
    @identifiers = fhir_coverage.identifier
    @payors = get_payors(fhir_coverage.payor, organizations)
    @period_start = dateToString(fhir_coverage.period.start) if fhir_coverage.period
    @period_end = dateToString(fhir_coverage.period.end) if fhir_coverage.period
    @relationship = codeable_concept_to_string(fhir_coverage.relationship)
    @subscriberId = fhir_coverage.subscriberId
    @type = codeable_concept_to_string(fhir_coverage.type)
    @classes = get_classes(fhir_coverage.local_class)
  end

  def get_payors(payor_refs, organizations)
    payor_ids = payor_refs.map { |payor| get_id_from_reference(payor.reference) }
    payor_ids.map { |id| elementwithid(organizations, id) }
  end
  
  def get_classes(fhir_classes)
    fhir_classes.map do |c|
      Struct.new(*[:name, :value, :type])
            .new(*[c.name, c.value, codeable_concept_to_string(c.type)])
    end
  end
  
end