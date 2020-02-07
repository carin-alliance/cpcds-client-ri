################################################################################
#
# Application Controller
#
# Copyright (c) 2019 The MITRE Corporation.  All rights reserved.
#
################################################################################

class ApplicationController < ActionController::Base
    attr_accessor :explanationofbenefits, :practitioners, :patients, :locations, :organizations, :practitionerroles, :encounters,
    :observations, :procedures, :immunizations, :diagnosticreports, :documentreferences, :claims, :conditions, :medicationrequests,
    :careteams, :careplans, :devices, :provenances

   def load_bundle
    # read a bundle from a file
    file = File.read('../cpcds-server-ri/CPCDS_patient_data/Ariadna374_Aragón562.json')
    @bundle = FHIR::Json.from_json(file)
    @bundleCountsByType = @bundle.entry.map { | entry | entry.resource.resourceType}.group_by{|e| e}.map{|k, v| [k, v.length]}.to_h
    @patients ||= @bundle.entry.select { |entry| entry.resource.instance_of? FHIR::Patient }.map(&:resource)
    @locations ||= @bundle.entry.select { |entry| entry.resource.instance_of? FHIR::Location }.map(&:resource)
    @organizations ||= @bundle.entry.select { |entry| entry.resource.instance_of? FHIR::Organization }.map(&:resource)
    @practitioners ||= @bundle.entry.select { |entry| entry.resource.instance_of? FHIR::Practitioner }.map(&:resource)
    @practitionerroles ||= @bundle.entry.select { |entry| entry.resource.instance_of? FHIR::PractitionerRole }.map(&:resource)
    @encounters ||= @bundle.entry.select { |entry| entry.resource.instance_of? FHIR::Encounter }.map(&:resource)
    @observations ||= @bundle.entry.select { |entry| entry.resource.instance_of? FHIR::Observation }.map(&:resource)
    @procedures ||= @bundle.entry.select { |entry| entry.resource.instance_of? FHIR::Procedure }.map(&:resource)
    @immunizations ||= @bundle.entry.select { |entry| entry.resource.instance_of? FHIR::Immunization }.map(&:resource)
    @diagnosticreports ||= @bundle.entry.select { |entry| entry.resource.instance_of? FHIR::DiagnosticReport }.map(&:resource)
    @documentreferences ||= @bundle.entry.select { |entry| entry.resource.instance_of? FHIR::DocumentReference }.map(&:resource)
    @claims ||= @bundle.entry.select { |entry| entry.resource.instance_of? FHIR::Claim }.map(&:resource)
    @explanationofbenefits ||= @bundle.entry.select { |entry| entry.resource.instance_of? FHIR::ExplanationOfBenefit }.map(&:resource)
    @conditions ||= @bundle.entry.select { |entry| entry.resource.instance_of? FHIR::Condition }.map(&:resource)
    @medicationrequests ||= @bundle.entry.select { |entry| entry.resource.instance_of? FHIR::MedicationRequest }.map(&:resource)
    @careteams ||= @bundle.entry.select { |entry| entry.resource.instance_of? FHIR::CareTeam }.map(&:resource)
    @careplans ||= @bundle.entry.select { |entry| entry.resource.instance_of? FHIR::CarePlan }.map(&:resource)
    @devices ||= @bundle.entry.select { |entry| entry.resource.instance_of? FHIR::Device }.map(&:resource)
    @provenances ||= @bundle.entry.select { |entry| entry.resource.instance_of? FHIR::Provenance }.map(&:resource)
   end

    def getPractitioner(id)
        practitioners.select{|p| p.id==cleanup(id)}
    end
    def getClaim(id)
        claims.select{|p| p.id==cleanup(id)}
    end
    def getProcedure(id)
        procedures.select{|p| p.id==cleanup(id)}
    end
    def getEncounter(id)
        encounters.select{|p| p.id==cleanup(id)}
    end

     def cleanup(id)
        id.gsub("urn:uuid:", "")
     end

end
