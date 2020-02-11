

################################################################################
#
# Medication Model
#
# Copyright (c) 2019 The MITRE Corporation.  All rights reserved.
#
################################################################################

class Observation  < Resource

	include ActiveModel::Model

  attr_reader :id, :category, :code, :components, :date, :sortDate 

  #-----------------------------------------------------------------------------

  def initialize(fhir_observation)
      @id 	= fhir_observation.id
      @sortDate = DateTime.parse(fhir_observation.effectiveDateTime).to_i 
      @date = DateTime.parse(fhir_observation.effectiveDateTime).strftime("%m/%d/%Y")
    @category = fhir_observation.category.map(&:coding)[0].map(&:display).join(",")
    @code = fhir_observation.code.text
    @value = valueToString(fhir_observation)
    if @value == "none" then
        @components = get_components(fhir_observation.component)
    else
        @components = [{
            :code => @code,
            :value => @value
        }]
    end 

  end




  def get_components(fhir_components)
    fhir_components.map{ |comp| 
       {
           :code => comp.code.text,
           :value => valueToString(comp)
       }
    }
  end
  def valueToString(obj)
    value = "none"
    value = obj.valueBoolean  if obj.valueBoolean
    value = obj.valueCodeableConcept.display if obj.valueCodeableConcept
    value = obj.valueDateTime if obj.valueDateTime
    value = obj.valueInteger if obj.valueInteger
    value = obj.valuePeriod if obj.valuePeriod
    value = sprintf('%.2f',obj.valueQuantity.value) + obj.valueQuantity.unit if obj.valueQuantity 
    value = obj.valueRange if obj.valueRange 
    value = obj.valueRatio if obj.valueRatio
    value = obj.valueSampledData if obj.valueSampledData  
    value = obj.valueString if obj.valueString 
    value = obj.valueTime if obj.valueTime   
    value 
  end

  #-----------------------------------------------------------------------------


end

