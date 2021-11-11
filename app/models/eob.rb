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
  attr_accessor :id, :created, :billingstartdate, :billingenddate, :category, :careteam, :claim_reference, :claim, :facility, :use, :insurer, :provider, 
      :coverage, :items, :fhir_client, :sortDate, :total, :payment, :supportingInfo, :patient,  :payeetype, :payeeparty, :type, :adjudication , :outcome, :use

  def initialize(fhir_client, fhir_eob, patients, practitioners, locations, organizations, coverages, practitionerroles)
    @id = fhir_eob.id
    @type = CLAIM_TYPE_CS[codingToString(fhir_eob.type&.coding)]
    if @type == "Institutional" 
      subtype = CLAIM_SUBTYPE_CS[codingToString(fhir_eob.subType&.coding)]
      @type = "#{@type} (#{subtype})"
    end
    @use = fhir_eob.use
    @patient = patients[0].names 
    @sortDate = DateTime.parse(fhir_eob.created).to_i
    @created = dateToString(fhir_eob.created)
    @billingstartdate = dateToString(fhir_eob.billablePeriod&.start)
    @billingenddate = dateToString(fhir_eob.billablePeriod&.end)
    insurer_id = get_id_from_reference(fhir_eob.insurer.reference)
    i  = elementwithid(organizations, insurer_id)
    @insurer = i ? i : Struct.new(*[:name, :telecoms, :addresses]).new(*['missing', [], []])
    provider_id = get_id_from_reference(fhir_eob.provider.reference)
    p = (elementwithid(practitioners, provider_id) || elementwithid(organizations, provider_id))
    @provider = p ? p : Struct.new(*[:name, :telecoms, :addresses]).new(*['missing', [], []])
    @payeetype = codeable_concept_to_string(fhir_eob.payee&.type)
    payeeparty_id = get_id_from_reference(fhir_eob.payee&.party&.reference)
    @payeeparty = fhir_eob.payee ? (elementwithid(patients, payeeparty_id) || elementwithid(practitioners, payeeparty_id) || elementwithid(organizations, payeeparty_id)) : "none"
    @outcome = fhir_eob.outcome 
=begin  @careteam = fhir_eob.careTeam.each_with_object({}) do |member, hash|
             sequence = member.sequence
             practitioner =  elementwithid( practitioners, member.provider.reference )
             name = practitioner.name[0]
             rendername = name.prefix.join(" ") if name.prefix
             rendername = rendername + " " + name.given.join(" ") + " " + name.family 
             hash[sequence] = { :name => rendername,
                                 :role =>  member.role.coding.map {|coding| coding.display}.join(",")
              }
    end
     @careteam = fhir_eob.careTeam
=end
    if fhir_eob.diagnosis 
      @diagnosis = fhir_eob.diagnosis.each_with_object({}) do |d, hash|
        sequence = d.sequence
        codeable = codingToString(d.diagnosisCodeableConcept.coding)
        type = codingToString(d.type.map(&:coding).flatten)
        hash[sequence]  = {:code => codeable, :type => type}
      end
    end
    
    @facility =  fhir_eob.facility.display  || "<MISSING>"
    @use = fhir_eob.use || "<MISSING>"
    @total =  parseTotal(fhir_eob.total) 
    @payment = fhir_eob.payment && fhir_eob.payment.amount ? amountToString(fhir_eob.payment.amount) : "<MISSING>"  
    @paymenttype= fhir_eob.payment ? codingToString(fhir_eob.payment.type.coding) : "<MISSING>"  
    @paymentdate=  fhir_eob.payment ? dateToString(fhir_eob.payment.date) : "<MISSING>"  
    @supportingInfo = parseSupportingInfo(fhir_eob.supportingInfo, fhir_client)
    coverage_id = get_id_from_reference(fhir_eob.insurance&.first&.coverage&.reference)
    @coverage = elementwithid(coverages,coverage_id)  
    @items = parseItems(fhir_eob.item) if fhir_eob.item 
    @adjudication = parseAdjudication(fhir_eob.adjudication) 
  end

  def parseTotal(total)
    total.map{ |item|
      {
      :category => codeable_concept_to_string(item.category),
      :amount => "$#{item.amount.value}"
      }
    }
  end

  def parseSupportingInfo(supportingInfo, fhir_client)
    hash = {}
    supportingInfoHash = supportingInfo.each_with_object({}) do |member, hash|
      sequence = member.sequence
      category_code = codingToString(member.category.coding)
      category = SUPPORTING_INFO_CS[category_code] ||ADJUDICATION_CS[category_code]
      info = 'missing'
      info = codingToString(member.code.coding) if member.code
      info = "#{ADA_UNIVERSAL_NS[info]} (#{info})" if category == "Additional Body Site"  #TODO: to be revised for all EOB profiles
      info = dateToString(member.timingDate) if member.timingDate
      info = ("#{dateToString(member.timingPeriod.start)} - #{dateToString(member.timingPeriod.end)}") if member.timingPeriod
      info = member.valueBoolean ||member.valueString ||member.valueQuantity&.value || info
      if member.valueReference
        resource = fhir_client.read(nil, member.valueReference.reference).resource
        info = resource.name
      end
      
      hash[sequence] = { :category => category, :info => info.to_s }
    end
    supportingInfoHash.sort_by { |seq, h| seq }.to_h
  end

  def parseAdjudication(adjudication)
    adjudication ||= []

    adjudication.map do |item|
      amount = type = reason = value = 'N/A'
      type = ADJUDICATION_CS[codingToString(item.category.coding)] || type
      amount = amountToString(item.amount)
      reason = item.reason.present? ? codeable_concept_to_string(item.reason) : reason
      value = item.value || value
      {
        :type => type,
        :amount => amount,
        :value => value,
        :reason => reason 
      }
    end
  end

  def parseItems(items)
    items ||= []

    items.map do | item | 
      itemloc = item.locationCodeableConcept.present? ? 
                "#{item.locationCodeableConcept.coding&.first&.display} (#{codingToString(item.locationCodeableConcept.coding)})" 
                : 'N/A'
      itemproductOrService = "#{item.productOrService&.coding&.first&.display} (#{codingToString(item.productOrService&.coding)})"
      itemstartDate = item.servicedDate.present? ? dateToString(item.servicedDate) : @billingstartdate

      itemadjudication = item.adjudication&.map do |adj|  
        value = amountToString(adj.amount) 
        type = ADJUDICATION_CS[codingToString(adj.category.coding)]
        text = adj.category&.text
        adjvalue = {type: type, value: value, text: text}
      end

      revenue = codeable_concept_to_string(item.revenue)
      {
        :revenue => revenue,
        :diagnosisSequence =>item.diagnosisSequence,
        :procedureSequence =>item.procedureSequence,
        :careteamSequence =>item.careTeamSequence,
        :informationSequence =>item.informationSequence,
        :location => itemloc,
        :productOrService => itemproductOrService,
        :startDate => itemstartDate,
        :adjudication => itemadjudication,
        :quantity => item.quantity 
      }
    end
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
