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
   attr_accessor :id, :created, :billingstartdate, :billingenddate, :category, :careteam, :claim_reference, :claim, :facility, :use, :insurer, :provider, :contained,
      :coverage, :items, :fhir_client, :sortDate, :claimpatient,:total, :payment, :supportingInfo

  def initialize(fhir_eob, fhir_resources, fhir_client)
    @id = fhir_eob.id
    @sortDate = DateTime.parse(fhir_eob.created).to_i
    @created = DateTime.parse(fhir_eob.created).strftime("%m/%d/%Y")
    @billingstartdate = DateTime.parse(fhir_eob.billablePeriod.start).strftime("%m/%d/%Y")
    @billingenddate = DateTime.parse(fhir_eob.billablePeriod.end).strftime("%m/%d/%Y")
    @careteam = fhir_eob.careTeam.each_with_object({}) do |member, hash|
            sequence = member.sequence
            practitioner =  get_fhir_resources(fhir_client, FHIR::Practitioner, member.provider.reference)[0]
            name = practitioner.name[0]
            rendername = name.prefix.join(" ") if name.prefix
            rendername = rendername + " " + name.given.join(" ") + " " + name.family 
            hash[sequence] = { :name => rendername,
                                :role =>  member.role.coding.map {|coding| coding.display}.join(",")
             }
    end
    if fhir_eob.diagnosis 
        @diagnosis = fhir_eob.diagnosis.each_with_object({}) do |d, hash|
          sequence = d.sequence
          codeable = ""
          d.diagnosisCodeableConcept.map(&:coding).map {|e|  e[0]}.map{|e| e.display + "(" + e.code + ")"}.flatten.join(",") if d.diagnosisCodeableConcept 
          type = d.type.map(&:coding).map {|e|  e[0]}.map(&:code).flatten.join(",")
          hash[sequence]  = {:code => codeable, :type => type }
        end
    end

    @claim_reference = fhir_eob.claim.reference
    claim = get_fhir_resources(fhir_client, FHIR::Claim, @claim_reference.split("/")[1])[0]
    binding.pry  if claim == nil || claim.patient == nil 
    @claimpatient= claim.patient.display 
    @supportingInfo = claim.supportingInfo
    @facility =  fhir_eob.facility.display     
    @use = fhir_eob.use || "<MISSING>"
    @insurer = fhir_eob.insurer.display || "<MISSING>"
    @provider = fhir_eob.provider.display || "<MISSING>"
    @total =  [ fhir_eob.total[0].category.text, "$"+sprintf('%.2f',fhir_eob.total[0].amount.value)] || []
    @payment = "$"+sprintf('%.2f',fhir_eob.payment.amount.value) || "<MISSING>"  
    @contained = fhir_eob.contained.each_with_object({}) do |object, hash|
      hash[object.id] = object.class.to_s
    end
    @coverage = fhir_eob.insurance[0].coverage.display  
  
    @items = fhir_eob.item.map { | item | 
      itemenc = item.encounter.map(&:reference)
      itemenc = ["none"] unless itemenc.length > 0 
      itemloc = item.location.coding.map(&:display)
      itemloc = ["none"] unless itemloc.length
      itemproductOrService = item.productOrService.text
      itemproductOrService = ["none"] unless item.productOrService.text
      itemstartDate = DateTime.parse(item.servicedPeriod.start).strftime("%m/%d/%Y")
      itemstartTime = DateTime.parse(item.servicedPeriod.start).strftime("%m/%d/%Y %H:%M")
      itemendTime = DateTime.parse(item.servicedPeriod.start).strftime("%m/%d/%Y %H:%M")
      # Strip off line that means nothing.
      # Always return entries in the same order, then strip off first character.
      itemadjudication = item.adjudication.map{ | adj|  
          value = "missing"  ;
          value = "$"+ sprintf('%.2f',adj.amount.value) if adj.amount ;
          adjText = @@adjudicationToText[adj.category.coding[0].code]
          adjvalue = [value,  adjText ]   if adjText
      }.compact.sort_by { |el| el[1] }.map {|e| [e[0], e[1][1..-1]]}
   
      category = item.category.coding.map(&:display)
      category = ["none"] unless category.length > 0
      {
      :category => category,
      #:encounter => itemenc,
      #:observations => observations,
      :diagnosisSequence =>item.diagnosisSequence,
      :procedureSequence =>item.procedureSequence,
      :careteamSequence =>item.careTeamSequence,
      :informationSequence =>item.informationSequence,
      :location => itemloc,
      :productOrService => itemproductOrService,
      :startDate => itemstartDate,
      :startTime => itemstartTime,
      :endTime => itemendTime,
      :adjudication => itemadjudication,
      :revenue => item.revenue,
      :quantity => item.quantity 
      }
    }
  	@fhir_client			= fhir_client
end
  #-----------------------------------------------------------------------------

  def valueToText(obs)
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
end   

@@adjudicationToText = {
  "https://bluebutton.cms.gov/resources/variables/line_alowd_chrg_amt" => "2Allowed Charge",
  "https://bluebutton.cms.gov/resources/variables/line_sbmtd_chrg_amt" => "1Submitted Charge",
  "https://bluebutton.cms.gov/resources/variables/line_prvdr_pmt_amt" => "3Paid to Provider",
  "https://bluebutton.cms.gov/resources/variables/line_bene_ptb_ddctbl_amt" => "4You Owe (Deductible)",
  "https://bluebutton.cms.gov/resources/variables/line_coinsrnc_amt" => "5You Owe (Coinsurance)"
}


 

end
