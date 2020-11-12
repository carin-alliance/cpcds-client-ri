################################################################################
#
# Patient Model
#
# Copyright (c) 2019 The MITRE Corporation.  All rights reserved.
#
################################################################################

class Patient < Resource

	include ActiveModel::Model

  attr_reader :id, :names, :telecoms, :addresses, :birth_date, :gender, 
                  :marital_status, :photo
                  #, :observations, :medications, :procedures, :conditions, :docrefs, :immunizations 

  #-----------------------------------------------------------------------------

  def initialize(fhir_patient)
          @id               = fhir_patient.id
          @names 						= fhir_patient.name
          @telecoms 				= fhir_patient.telecom
          @addresses 				= fhir_patient.address
          @birth_date 			= fhir_patient.birthDate.to_date
          @gender 					= fhir_patient.gender
          if fhir_patient.maritalStatus
            @marital_status = fhir_patient.maritalStatus.text
          else
            @marital_status = "none"
          end
          @photo						= nil
  end

=begin #---------------------------
def get_docrefs (fhir_docrefs)
  docrefs = []

   fhir_docrefs.each do |fhir_docref|
    docrefs << DocumentReference.new(fhir_docref) unless fhir_docref.nil?
  end

  return docrefs.sort_by { |a|  -a.sortDate }
end

#---------------------------
def get_immunizations (fhir_immunizations)
  immunizations = []

  fhir_immunizations.each do |fhir_immunization|
    immunizations << Immunization.new(fhir_immunization) unless fhir_immunization.nil?
  end

  return immunizations.sort_by { |a|  -a.sortDate }
end


  #-----------------------------------------------------------------------------

def get_conditions (fhir_conditions)
  conditions = []

  # /MedicationRequest?patient=[@id]&_include=MedicationRequest:medication
=begin search_param = 	{ search: 
                    { parameters: 
                      { 
                        patient: @id, 
                        _include: ['MedicationRequest:medication'] 
                      } 
                    } 
                  }

  fhir_bundle = @fhir_client.search(FHIR::MedicationRequest, search_param).resource
  fhir_medications = filter(fhir_bundle.entry.map(&:resource), 'Medication')

   
   fhir_conditions.each do |fhir_condition|
    conditions << Condition.new(fhir_condition) unless fhir_condition.nil?
  end

  return conditions.sort_by { |a|  -a.sortDate }
end

  #-----------------------------------------------------------------------------

  def get_medications (fhir_medications)
  	medications = []

  	# /MedicationRequest?patient=[@id]&_include=MedicationRequest:medication
=begin search_param = 	{ search: 
    									{ parameters: 
    										{ 
                          patient: @id, 
    											_include: ['MedicationRequest:medication'] 
    										} 
    									} 
    								}

    fhir_bundle = @fhir_client.search(FHIR::MedicationRequest, search_param).resource
    fhir_medications = filter(fhir_bundle.entry.map(&:resource), 'Medication')

     
     fhir_medications.sort_by{| med | DateTime.parse(med.authoredOn).to_i}
     fhir_medications.each do |fhir_medication|
    	medications << Medication.new(fhir_medication) unless fhir_medication.nil?
    end

    return medications.sort_by { |a|  -a.sortDate }
  end
  #-----------------------------------------------------------------------------
  def get_observations (fhir_observations)
  	observations = []

  	# /Observation?patient=[@id]&_include=Observation:observation
=begin search_param = 	{ search: 
    									{ parameters: 
    										{ 
                          patient: @id, 
    											_include: ['Observation:observation'] 
    										} 
    									} 
    								}

    fhir_bundle = @fhir_client.search(FHIR::Observation, search_param).resource
    fhir_medications = filter(fhir_bundle.entry.map(&:resource), 'Observation')


    fhir_observations.each do |fhir_observation|
    	observations << Observation.new(fhir_observation) unless fhir_observation.nil?
    end

    return observations.sort_by { |a| [  -a.sortDate, a.category ] }
  end

    
   #-----------------------------------------------------------------------------
   def get_procedures (fhir_procedures)
  	procedures = []

  	# /Procedure?patient=[@id]&_include=MedicationRequest:medication
search_param = 	{ search: 
    									{ parameters: 
    										{ 
                          patient: @id, 
    											_include: ['MedicationRequest:medication'] 
    										} 
    									} 
    								}

    fhir_bundle = @fhir_client.search(FHIR::MedicationRequest, search_param).resource
    fhir_medications = filter(fhir_bundle.entry.map(&:resource), 'Medication')

     
     fhir_procedures.each do |fhir_procedure|
    	procedures << Procedure.new(fhir_procedure) unless fhir_procedure.nil?
    end

    return procedures.sort_by { |a|  -a.sortDate }
  end

=end


  def age
    now = Time.now.to_date
    age = now.year - @birth_date.year

    if now.month < @birth_date.month || 
                  (now.month == @birth_date.month && now.day < @birth_date.day)
      age -= 1
    end

    age.to_s
  end

  #-----------------------------------------------------------------------------
  private
  #-----------------------------------------------------------------------------

  def filter(fhir_resources, type)
    fhir_resources.select do |resource| 
    	resource.resourceType == type
    end
  end

  #-----------------------------------------------------------------------------

  def get_fhir_statuses_with_profile(profile)
    search_param =  { search:
                      { parameters:
                        { 
                          patient: @id,
                          _profile: profile 
                        }
                      }
                    }

    fhir_bundle = @fhir_client.search(FHIR::Observation, search_param).resource
    fhir_statuses = fhir_bundle.entry.map(&:resource)
  end

end