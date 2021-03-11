# frozen_string_literal: true

require "erb"
require "hanami/version"

module Hanami
  module CLI
    module Generators
      class Context
        def initialize(inflector, app)
          @inflector = inflector
          @app = app
        end

        def ctx
          binding
        end

        def hanami_version
          Hanami::Version.gem_requirement
        end

        def classified_app_name
          inflector.classify(app)
        end

        def underscored_app_name
          inflector.underscore(app)
        end

        private

        attr_reader :inflector

        attr_reader :app
      end

      module Application
        class Monolith
          def initialize(fs:, inflector:)
            super()
            @fs = fs
            @inflector = inflector
          end

          def call(app, context: Context.new(inflector, app)) # rubocop:disable Metrics/AbcSize
            fs.write(".env", t("env.erb", context))

            fs.write("README.md", t("readme.erb", context))
            fs.write("Gemfile", t("gemfile.erb", context))
            fs.write("Rakefile", t("rakefile.erb", context))
            fs.write("config.ru", t("config_ru.erb", context))

            fs.write("config/application.rb", t("application.erb", context))
            fs.write("config/settings.rb", t("settings.erb", context))
            fs.write("config/routes.rb", t("routes.erb", context))

            fs.write("lib/tasks/.keep", t("keep.erb", context))

            fs.write("lib/#{app}/entities/.keep", t("keep.erb", context))
            fs.write("lib/#{app}/persistence/relations/.keep", t("keep.erb", context))
            fs.write("lib/#{app}/validation/contract.rb", t("validation_contract.erb", context))
            fs.write("lib/#{app}/view/context.rb", t("view_context.erb", context))
            fs.write("lib/#{app}/action.rb", t("action.erb", context))
            fs.write("lib/#{app}/entities.rb", t("entities.erb", context))
            fs.write("lib/#{app}/functions.rb", t("functions.erb", context))
            fs.write("lib/#{app}/operation.rb", t("operation.erb", context))
            fs.write("lib/#{app}/repository.rb", t("repository.erb", context))
            fs.write("lib/#{app}/types.rb", t("types.erb", context))
          end

          private

          attr_reader :fs

          attr_reader :inflector

          def template(path, context)
            require "erb"

            ERB.new(
              File.read(__dir__ + "/monolith/#{path}")
            ).result(context.ctx)
          end

          alias_method :t, :template
        end
      end
    end
  end
end