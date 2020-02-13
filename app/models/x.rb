################################################################################
#
# DocRef Model
#
# Copyright (c) 2019 The MITRE Corporation.  All rights reserved.
#
################################################################################
#  Can't name it much of anything beyond one letter, or I get an error...why?
class X < Resource


    include ActiveModel::Model
  
    attr_reader :id, :attachment, :dateTime,  :sortDate, :category, :type,
     :author, :category
  
    #-----------------------------------------------------------------------------
  
    def initialize(fhir_docref)
      @id 	= fhir_docref.id
      @sortDate  =   DateTime.parse(fhir_docref.date).to_i
      @dateTime =   DateTime.parse(fhir_docref.date).strftime("%m/%d/%Y")
      @attachment =  Base64.decode64(fhir_docref.content[0].attachment.data)
      @author = fhir_docref.author.map(&:display).join(";")
      @category = getCodeableConceptDisplay(fhir_docref.category[0])
      @type = fhir_docref.type.coding.map(&:display).join(",")
  
    end
  
    #-----------------------------------------------------------------------------
    def getCodeableConceptDisplay (codeableconcept)
        codeableconcept.coding.map(&:display).join(",")
    end 
  
  end