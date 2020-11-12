class Organization  < Resource

	include ActiveModel::Model

    attr_reader :id, :names, :telecoms, :addresses

def initialize(fhir_organization)
    @id               = fhir_organization.id
    @names 				= fhir_organization.name
    @telecoms 			= fhir_organization.telecom
    @addresses 			= fhir_organization.address
end

end
