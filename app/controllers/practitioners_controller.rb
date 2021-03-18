################################################################################
#
# Practitioners Controller
#
# Copyright (c) 2020 The MITRE Corporation.  All rights reserved.
#
################################################################################

class PractitionersController < ApplicationController

	def show
	  # This search should be from resources included in EOB search
		fhir_client = SessionHandler.fhir_client(session.id)
    fhir_practitioner = fhir_client.read(FHIR::Practitioner, params[:id]).resource

    @practitioner = Practitioner.new(fhir_practitioner) unless fhir_practitioner.nil?
	end
	
end
