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
      :coverage, :items, :fhir_client, :sortDate, :total, :payment, :supportingInfo, :patient,  :payeetype, :payeeparty, :type, :adjudication , :outcome 

  def initialize(fhir_eob, patients, practitioners, locations, organizations, coverages, practitionerroles)
    @id = fhir_eob.id
    @type = fhir_eob.type.coding[0].code
    if @type == "institutional" 
      if fhir_eob.meta.profile[0].include?("Inpatient")
        @type = "inpatient"
      else
        @type = "outpatient"
      end
    end
    @patient = patients[0].names 
    @sortDate = DateTime.parse(fhir_eob.created).to_i
    @created = DateTime.parse(fhir_eob.created).strftime("%m/%d/%Y")
    @billingstartdate = fhir_eob.billablePeriod ? DateTime.parse(fhir_eob.billablePeriod.start).strftime("%m/%d/%Y") : "none"
    @billingenddate = fhir_eob.billablePeriod ? DateTime.parse(fhir_eob.billablePeriod.end).strftime("%m/%d/%Y") : "none"
    insurer_id = get_id_from_reference(fhir_eob.insurer.reference)
    i  = elementwithid(organizations, insurer_id)
    @insurer = i ? i : Struct.new(*[:name, :telecoms, :addresses]).new(*['None', [], []])
    provider_id = get_id_from_reference(fhir_eob.provider.reference)
    p = (elementwithid(practitioners, provider_id) || elementwithid(organizations, provider_id))
    @provider = p ? p : Struct.new(*[:name, :telecoms, :addresses]).new(*['None', [], []])
    @payeetype = fhir_eob.payee ? codingToString(fhir_eob.payee.type.coding) : "none"
    @payeeparty = fhir_eob.payee ? (elementwithid(patients, fhir_eob.payee.party) || elementwithid(practitioners, fhir_eob.payee.party) || elementwithid(organizations, fhir_eob.payee.party)) : "none"
    @outcome = fhir_eob.outcome 
=begin  @careteam = fhir_eob.careTeam.each_with_object({}) do |member, hash|
             sequence = member.sequence
             #     #     binding.pry 
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
    #@supportingInfo = claim.supportingInfo
    @facility =  fhir_eob.facility.display  || "<MISSING>"
    @use = fhir_eob.use || "<MISSING>"
    @total =  parseTotal(fhir_eob.total) 
    @payment = fhir_eob.payment && fhir_eob.payment.amount ? amountToString(fhir_eob.payment.amount) : "<MISSING>"  
    # byebug 
    @paymenttype= fhir_eob.payment ? codingToString(fhir_eob.payment.type.coding) : "<MISSING>"  
    @paymentdate=  fhir_eob.payment ? dateToString(fhir_eob.payment.date) : "<MISSING>"  
    @supportingInfo = parseSupportingInfo(fhir_eob.supportingInfo)
    #@contained = fhir_eob.contained.each_with_object({}) do |object, hash|
    #  hash[object.id] = object.class.to_s
    #end
    coverage_id = get_id_from_reference(fhir_eob.insurance.first.coverage.reference)
    @coverage = elementwithid(coverages,coverage_id)  
    #     #     binding.pry 
    @items = parseItems (fhir_eob.item) if fhir_eob.item 
    @adjudication = parseAdjudication(fhir_eob.adjudication) 
  end

  def parseTotal(total)
    total.map{ |item|
      {
      :category => codingToString(item.category.coding),
      :amount => "$#{item.amount.value}"
      }
    }
  end

  def parseSupportingInfo(supportingInfo)
    hash = {}
    supportingInfoHash = supportingInfo.each_with_object({}) do |member, hash|
      sequence = member.sequence
      category = codingToString(member.category.coding)
      code = ( member.code ? codingToString(member.code.coding) : "none" )
      timing = member.timingPeriod || member.timingDate
      hash[sequence] = { :category => category,
                         :timing => timing,
                         :code => code}
    end
  end

  def parseAdjudication(adjudication)
    adjudication.map do |item|
      amount = type = reason = units = value = nil
      case 
      when item.category.coding[0].code == "denialreason"
        slice = :denialreason
        reason = codingToString(item.denialReason.coding)
      when item.category.coding[0].code == "allowedunits"
        slice = :allowedunits
        units = codingToString(item.denialReason.coding)
        value = item.value 
      else
        slice = :adjudicationamounttype
        type = codingToString(item.category.coding)
        amount = item.amount ? amountToString(item.amount) : "missing"
      end
      {
        :slice => slice.to_s,
        :type => type,
        :amount => amount,
        :value => value,
        :units => units,
        :reason => reason 
      }
    end
  end


  def amountToString(amount)
    "$"+ sprintf('%.2f',amount.value)
  end

  def codingToString(coding)
    coding ? coding.map{|e| (e.display ? e.display : "none") +  "(" + e.code + ")" }.flatten.join(",") : "none"
  end

  def parseItems(items)
    items.map do | item | 
      itemenc = item.encounter.map(&:reference)
      itemenc = ["none"] unless itemenc.length > 0 
      itemloc = item.location ? item.location.coding.map(&:display).join(",") : "none"
      itemproductOrService = codingToString(item.productOrService.coding)
      itemstartDate = item.servicedPeriod ? DateTime.parse(item.servicedPeriod.start).strftime("%m/%d/%Y") : ""
      itemstartTime = item.servicedPeriod ? DateTime.parse(item.servicedPeriod.start).strftime("%m/%d/%Y %H:%M") :  ""
      itemendTime = item.servicedPeriod ? DateTime.parse(item.servicedPeriod.start).strftime("%m/%d/%Y %H:%M") : ""

      # Strip off line that means nothing.
      # Always return entries in the same order, then strip off first character.
      itemadjudication = item.adjudication.map do |adj|  
        value = adj.amount ? amountToString(adj.amount) : "missing" 
        adjText = codingToString(adj.category.coding)
        adjvalue = [value, adjText] if adjText
      end

      # binding.pry 
      revenue = item.revenue ? codingToString(item.revenue.coding) : "missing"
      {
        :revenue => revenue,
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
