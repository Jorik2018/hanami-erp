# frozen_string_literal: true

require "pathname"
SPEC_ROOT = Pathname(__dir__).realpath.freeze

ENV["HANAMI_ENV"] ||= "test"
require "hanami/prepare"

SPEC_ROOT.glob("support/**/*.rb").each { |f| require f }


require "simplecov"

SimpleCov.start do
  enable_coverage :branch

  add_filter "/spec/"
  add_filter "/config/"

  add_group "Actions", "lib/hanami_erp/actions"
  add_group "Services", "lib/hanami_erp/services"
  #Ajusta las rutas de add_group si tus actions o servicios están en otra carpeta.
  minimum_coverage 80
end
