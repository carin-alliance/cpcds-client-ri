# frozen_string_literal: true

################################################################################
#
# Abstract Resource Model
#
# Copyright (c) 2019 The MITRE Corporation.  All rights reserved.
#
################################################################################

class Resource

  # Adds a warning message to the specified resource

  def warning(message)
    @warnings = [] unless @warnings.present?
    @warnings.append(message)
  end

  #-----------------------------------------------------------------------------

  # Adds an error message to the specified resource

  def error(message)
    @errors = [] unless @errors.present?
    @errors.append(message)
  end
  
  def get_fhir_resources(fhir_client, type, resource_id)
      search = { parameters: {  _id: resource_id} }
      results = fhir_client.search(type, search: search )
      results.resource.entry.map(&:resource)
  end

end
