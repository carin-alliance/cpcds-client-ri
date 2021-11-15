class Organization  < Resource

	include ActiveModel::Model

    attr_reader :id, :name, :telecoms, :addresses

def initialize(fhir_organization)
    @id             = fhir_organization.id
    @name    				= fhir_organization.name
    @telecoms 			= fhir_organization.telecom
    @addresses 			= fhir_organization.address
end

end
