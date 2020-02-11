################################################################################
#
# Patient Model
#
# Copyright (c) 2019 The MITRE Corporation.  All rights reserved.
#
################################################################################

class EOB < Resource

	include ActiveModel::Model
  #-----------------------------------------------------------------------------
   attr_accessor :id, :startdate, :enddate, :category, :careteam, :claim_reference, :claim, :facility, :use, :insurer, :provider, :contained,
      :coverage, :items, :fhir_client

  def initialize(fhir_eob, fhir_practitioners, fhir_claims, fhir_locations, fhir_observations, fhir_client)
    @id = fhir_eob.id
    @startdate = DateTime.parse(fhir_eob.billablePeriod.start).strftime("%m/%d/%Y")
    @enddate = DateTime.parse(fhir_eob.billablePeriod.end).strftime("%m/%d/%Y")
    @careteam = fhir_eob.careTeam.each_with_object({}) do |member, hash|
            reference = member.provider.reference.gsub("urn:uuid:", "")
            practitioner = fhir_practitioners.select{|p| p.id==reference}[0]
            name = practitioner.name[0]
            rendername = name.prefix.join(" ") if name.prefix
            rendername = rendername + " " + name.given.join(" ") + " " + name.family 
            hash[reference] = rendername + "(" + member.role.coding.map {|coding| coding.display}.join(",") + ")"  
    end
    @claim_reference = fhir_eob.claim.reference.gsub("urn:uuid:", "")
    @claim =  fhir_claims.select{|p| p.id==@claim_reference}[0]
    @facility =  fhir_eob.facility.display     
    @use = fhir_eob.use || "<MISSING>"
    @insurer = fhir_eob.insurer.display || "<MISSING>"
    @provider = fhir_eob.provider.display || "<MISSING>"
    @contained = fhir_eob.contained.each_with_object({}) do |object, hash|
      hash[object.id] = object.class.to_s
    end
    @coverage = fhir_eob.insurance[0].coverage.display    
    @items = fhir_eob.item.map { | item | 
      category = item.category.coding.map(&:display)
      category = ["none"] unless category.length > 0
      encounter = item.encounter.map {|enc|
           enc.reference.gsub("urn:uuid:", "")
      }
      encounter = ["none"] unless encounter.length > 0 
      observations = item.encounter.map {|enc|
         id = enc.id;
         observations = fhir_observations.select { |obs| obs.encounter.reference.gsub("urn:uuid:","") == reference}
         observations_extract = observations.map{ | obs |
          obscategory = obs.category.map(&:coding)[0].map(&:display).join(",")

          code = obs.code.text
          value = "nil"
          value = obs.valueBoolean  if obs.valueBoolean
          value = obs.valueCodeableConcept.display if obs.valueCodeableConcept
          value = obs.valueDateTime if obs.valueDateTime
          value = obs.valueInteger if obs.valueInteger
          value = obs.valuePeriod if obs.valuePeriod
          value = sprintf('%.2f',obs.valueQuantity.value) + obs.valueQuantity.unit if obs.valueQuantity 
          value = obs.valueRange if obs.valueRange 
          value = obs.valueRatio if obs.valueRatio
          value = obs.valueSampledData if obs.valueSampledData  
          value = obs.valueString if obs.valueString 
          value = obs.valueTime if obs.valueTime       
          {
            :id => id, 
            :category => obscategory,
            :code => code,
            :value => value
          }
         }
        }.flatten(1)
      location = item.location.coding.map(&:display)
      location = ["none"] unless location.length
      productOrService = item.productOrService.coding.map{ |p|  "<" + p.code + "> " + p.display }
      productOrService = ["none"] unless productOrService.length
      startTime = DateTime.parse(item.servicedPeriod.start).strftime("%m/%d/%Y %H:%M:%S")
      endTime = DateTime.parse(item.servicedPeriod.start).strftime("%m/%d/%Y %H:%M:%S")
      adjudication = item.adjudication.map{ | adj|  
          value = "missing"  ;
          value = "$"+ sprintf('%.2f',adj.amount.value) if adj.amount ;
          adjvalue = [value,  "("+adj.category.coding[0].display + ")"]  ;
      }
      {
      :category => category,
      :encounter => encounter,
      :observations => observations,
      :location => location,
      :productOrService => productOrService,
      :startTime => startTime,
      :endTime => endTime,
      :adjudication => adjudication
      }
  }
  	@fhir_client			= fhir_client
end
  #-----------------------------------------------------------------------------

end
