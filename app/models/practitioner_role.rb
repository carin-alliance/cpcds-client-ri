# frozen_string_literal: true

################################################################################
#
# PractitionerRole Model
#
# Copyright (c) 2019 The MITRE Corporation.  All rights reserved.
#
################################################################################

class PractitionerRole < Resource

    include ActiveModel::Model
  
    attr_reader :id, :meta, :identifier,
                   :telecoms, :organization, :specialties,
                  :practitioner 
  
    #-----------------------------------------------------------------------------
  
    def initialize(practitionerrole)
      @id = practitionerrole.id 
      @identifiers = practitionerrole.identifier
      @practitioner = practitionerrole.practitioner
      @organization = practitionerrole.organization
      @telecoms     = practitionerrole.telecom
      @specialties = practitionerrole.specialty
    end
  
  end