################################################################################
#
# Constants
#
# Copyright (c) 2019 The MITRE Corporation.  All rights reserved.
#
################################################################################

DEFAULT_SERVER = "http://hapi.fhir.org/baseR4"

#-------------------------------------------------------------------------------
# Claim Type Code System
CLAIM_TYPE_CS = {
  "institutional" => "Institutional",
  "oral" => "Oral",
  "pharmacy" => "Pharmacy",
  "professional" => "Professional",
  "vision" => "Vision",
}.freeze

#-------------------------------------------------------------------------------
# Claim Subtype CS
CLAIM_SUBTYPE_CS = {
  "inpatient" => "Inpatient",
  "outpatient" => "Outpatient",
}.freeze

#-------------------------------------------------------------------------------
# Supporting Info Code System
SUPPORTING_INFO_CS = {
  "billingnetworkcontractingstatus" => "Billing Network Contracting Status",
  "perfomingnetworkcontractingstatus" => "Performing Network Contracting Status",
  "clmrecvddate" => "Claim Received Date",
  "servicefacility" => "Service Facility",
  "patientaccountnumber" => "Patient Account Number",
  "admissionperiod" => "Admission Period",
  "pointoforigin" => "Point of Origin",
  "admtype" => "Admission Type",
  "brandgenericindicator" => "Brand Generic Indicator",
  "compoundcode" => "Compound Code",
  "dawcode" => "DAW (Dispense As Written) code",
  "dayssupply" => "Days Supply",
  "discharge-status" => "Discharge Status",
  "drg" => "Diagnosis Related Group (DRG)",
  "performingnetworkcontractingstatus" => "Performing Network Contracting Status",
  "refillnum" => "Refill Number",
  "refillsauthorized" => "Refills Authorized",
  "rxorigincode" => "Rx Origin Code",
  "typeofbill" => "Type of Bill",
  "medicalrecordnumber" => "Medical Record Number",
  "orthodontics" => "Orthodontics",
  "prosthesis" => "Prosthesis",
  "additionalbodysite" => "Additional Body Site",
  "missingtoothnumber" => "Missing Tooth Number",
  "patientweight" => "Patient Weight",
  "ambulancetransportreason" => "Ambulance Transport Reason",
  "transportationdistance" => "Transportation Distance",
  "roudtrippurpose" => "Roudtrip Purpose",
  "stretcherpurpose" => "Stretcher Purpose",
  "pickuplocation" => "Pickup Location",
  "dropofflocation" => "Dropoff Location",

}.freeze

#-------------------------------------------------------------------------------
# Adjudication Code System
TOTAL_CATEGORY_AND_ADJUDICATION_CS = {
  "submitted" => "Submitted Amount",
  "copay" => "CoPay",
  "eligible" => "Eligible Amount",
  "deductible" => "Deductible",
  "benefit" => "Benefit Amount",
  "coinsurance" => "Coinsurance",
  "noncovered" => "Non covered",
  "priorpayerpaid" => "Prior payer paid",
  "paidbypatient" => "Paid by patient",
  "paidtopatient" => "Paid to patient",
  "paidtoprovider" => "Paid to provider",
  "memberliability" => "Member liability",
  "discount" => "Discount",
  "drugcost" => "Drug cost",
  "innetwork" => "In Network",
  "outofnetwork" => "Out of Network",
  "other" => "Other Network",
  "allowedunits" => "Allowed units",
  "denialreason" => "Denial Reason",
  "adjustmentreason" => "Adjustment Reason",
  "rejectreason" => "Reject Reason",
  "billingnetworkstatus" => "Billing Network Status",
  "renderingnetworkstatus" => "Rendering Network Status",
  "benefitpaymentstatus" => "Benefit Payment Status",
}.freeze

#-------------------------------------------------------------------------------
ADA_UNIVERSAL_NS = {
  "1" => "Permanent teeth right maxillary third molar (wisdom tooth)",
  "2" => "Permanent teeth right second molar (12-year-molar)",
}.freeze
#-------------------------------------------------------------------------------
LOCATION_CS = {
  "01" => "Pharmacy",
  "11" => "Office",
  "12" => "Home",
  "13" => "Assisted Living Facility",
  "14" => "Group Home",
  "17" => "Walk-in Retail Health Clinic",
  "20" => "Urgent Care Facility",
  "21" => "Inpatient Hospital",
  "22" => "On Campus-Outpatient Hospital",
  "23" => "Emergency Room-Hospital",
}.freeze
#-------------------------------------------------------------------------------
PRODUCT_SERVICE_CS = {
  "99231" => "Subsequent Hospital Care",
  "75710" => "Lower Extremity Angiogram",
  "37228" => "Angioplasty",
}.freeze
