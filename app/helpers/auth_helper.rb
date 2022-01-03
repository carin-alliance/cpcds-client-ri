################################################################################
#
# Auth Helper
#
# Copyright (c) 2021 The MITRE Corporation.  All rights reserved.
#
################################################################################

module AuthHelper
  # Server auth helpers
  def get_server_metadata(server_url)
    begin
      rcRequest = RestClient::Request.new(
        :method => :get,
        :url => server_url + "/metadata",
      ).execute
    rescue StandardError => exception
      return "Unable to connect to the server: #{exception.message}"
    end
    rcResult = JSON.parse(eval(rcRequest).to_json)
    is_auth_server?(rcResult)
    rescue StandardError => exception
      return "Something went wrong when trying to get the server metadata. Please verify you provided a valid FHIR server."
  end

  def is_auth_server?(request_result)
    return false if request_result.nil?
    auth = !!request_result['rest']&.first&.has_key?('security')
    if auth
      session[:auth_url] = request_result["rest"][0]["security"]["extension"][0]["extension"].select { |e| e["url"] == "authorize" }[0]["valueUri"]
      session[:token_url] = request_result["rest"][0]["security"]["extension"][0]["extension"].select { |e| e["url"] == "token" }[0]["valueUri"]
    end
    session[:is_auth_server?] = auth
  end

  def set_server_auth_url
    # for Onyx     scope = "launch/patient openid fhirUser offline_access user/ExplanationOfBenefit.read user/Coverage.read user/Organization.read user/Patient.read user/Practitioner.read patient/ExplanationOfBenefit.read patient/Coverage.read patient/Organization.read patient/Patient.read patient/Practitioner.read"
    # scope = "launch/patient openid fhirUser offline_access user/*.read patient/*.read"
    scope = "launch/patient openid fhirUser offline_access patient/*.read"
    scope = scope.gsub(" ", "%20")
    scope = scope.gsub("/", "%2F")
    server_auth_url = session[:auth_url] +
                          "?response_type=code" +
                          "&redirect_uri=" + login_url +
                          "&aud=" + session[:iss_url] +
                          "&state=98wrghuwuogerg97" +
                          "&scope=" + scope +
                          "&client_id=" + session[:client_id]
  end

end
