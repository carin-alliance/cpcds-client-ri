# frozen_string_literal: true

################################################################################
#
# Practitioner Model
#
# Copyright (c) 2019 The MITRE Corporation.  All rights reserved.
#
################################################################################

class Practitioner < Resource
  include ActiveModel::Model

  attr_reader :id, :meta, :implicit_rules, :language, :text, :identifier,
              :active, :name, :telecoms, :addresses, :gender, :birthDate,
              :photo, :qualifications, :communications

  #-----------------------------------------------------------------------------

  def initialize(practitioner)
    @id = practitioner.id
    @name = read_full_name(practitioner.name)
    @telecoms = practitioner.telecom
    @addresses = practitioner.address
    @gender = practitioner.gender
    @birth_date = practitioner.birthDate
    @photo = practitioner.photo
    @qualifications = practitioner.qualification
    @communications = practitioner.communication
  end

  private

  def read_full_name(name = [])
    name = name&.first
    family = name&.family
    given = name&.given&.join(" ")
    suff = name&.suffix&.join(" ")
    full_name = "#{given} #{family}, #{suff}"
  end
end
