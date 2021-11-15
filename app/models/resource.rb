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

  #-----------------------------------------------------------------------------

  # Retrieving FHIR Resources

  def get_fhir_resources(fhir_client, type, resource_id, patient_id=nil)
    if patient_id == nil
        search = { parameters: {  _id: resource_id} } 
    else
        search = { parameters: {  _id: resource_id, patient: patient_id} }
    end
    results = fhir_client.search(type, search: search )
    
    results&.resource&.entry&.map(&:resource)
  end

  #-----------------------------------------------------------------------------

  def dateToString(date)
    date ? DateTime.parse(date).strftime("%m/%d/%Y") : '&lt;missing&gt;'
  end

  #-----------------------------------------------------------------------------

  def amountToString(amount)
    amount.present? ? "$#{sprintf('%.2f',amount.value)}" : '&lt;missing&gt;'
  end

  #-----------------------------------------------------------------------------

  def codingToString(coding)
    coding.present? ? coding.map(&:code).flatten.join(',') : '&lt;missing&gt;'
  end

  #-----------------------------------------------------------------------------
  # Get the element with a given id from the list
  def elementwithid(entries, id)
    hit = entries.find { |entry| entry.id == id } if entries.present?
  end

  #-----------------------------------------------------------------------------

  def get_id_from_reference(reference)
    reference.split('/').last if reference.present?
  end
  
  #-----------------------------------------------------------------------------

  def codeable_concept_to_string(code)
    begin
      info = code.coding.map(&:code).join(',')
      if text = code.display ||code.text
        info = "#{text} (#{info})"
      end
    rescue => exception
      info = '&lt;missing&gt;'
    end
    info.capitalize
  end

  #-----------------------------------------------------------------------------
end
