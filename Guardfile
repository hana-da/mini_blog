# frozen_string_literal: true

# Guardfile
# More info at https://github.com/guard/guard#readme

# rubocop:disable Metrics/BlockLength

## Uncomment and set this to only include directories you want to watch
# directories %w(app lib config test spec features) \
#  .select{|d| Dir.exist?(d) ? d : UI.warning("Directory #{d} does not exist")}

## Uncomment to clear the screen before every task
# clearing :on

## Note: if you are using the `directories` clause above and you are not
## watching the project directory ('.'), then you will want to move
## the Guardfile to a watched dir and symlink it back, e.g.
#
#  $ mkdir config
#  $ mv Guardfile config/
#  $ ln -s config/Guardfile .
#
# and, you'll have to watch "config/Guardfile" instead of "Guardfile"

# Note: The cmd option is now required due to the increasing number of ways
#       rspec may be run, below are examples of the most common uses.
#  * bundler: 'bundle exec rspec'
#  * bundler binstubs: 'bin/rspec'
#  * spring: 'bin/rspec' (This will use spring if running and you have
#                          installed the spring binstubs per the docs)
#  * zeus: 'zeus rspec' (requires the server to be started separately)
#  * 'just' rspec: 'rspec'

# This group allows to skip running RuboCop and Brakeman when RSpec failed.
group :red_green_refactor, halt_on_fail: true do
  guard :rspec, cmd: "RUBYLIB='#{ENV['RUBYLIB']}' WITHOUT_COV='true' bin/rspec" do
    require 'active_support/inflector'
    require 'guard/rspec/dsl'
    dsl = Guard::RSpec::Dsl.new(self)

    ##### Setting for target files and directories #####
    ## set Ruby files ##
    ruby = dsl.ruby

    ## set RSpec files and directories ##
    rspec = dsl.rspec
    rspec.support_dir     = "#{rspec.spec_dir}/support"
    rspec.models_dir      = "#{rspec.spec_dir}/models"
    rspec.features_dir    = "#{rspec.spec_dir}/features"
    rspec.controllers_dir = "#{rspec.spec_dir}/controllers"
    rspec.routing_dir     = "#{rspec.spec_dir}/routing"
    rspec.raketask_dir    = "#{rspec.spec_dir}/lib/tasks"

    rspec.factories = %r{^#{rspec.spec_dir}/factories/(.+)\.rb$}
    rspec.feature_spec = lambda do |m|
      parts = m.split('/')
      spec_file = File.join(parts[0..-2], parts[1..-1].join('_'))
      [
        rspec.spec.call(spec_file),
        "#{rspec.spec_dir}/#{spec_file}",
      ]
    end
    rspec.spec_support          = %r{^#{rspec.support_dir}/([^/]+)\.rb$}
    rspec.models_concerns       = %r{^#{rspec.support_dir}/models/concerns/.+\.rb$}
    rspec.features_applications = %r{^#{rspec.support_dir}/features/applications/.+\.rb$}

    ## set Rails files and directories ##
    view_extensions         = %w[erb haml slim]
    view_extensions_pattern = "(?:#{view_extensions.join('|')})"

    rails = dsl.rails(view_extensions: view_extensions)

    rails.models_concerns      = %r{^app/models/concerns/.+\.rb$}
    rails.controllers_concerns = %r{^app/controllers/concerns/.+\.rb$}

    rails.rake_tasks = %r{^lib/tasks/.+\.rake$}

    rails.layouts_dir = 'app/views/layouts'
    rails.layouts     = %r{^#{rails.layouts_dir}/([^.]+?)\.(?:[^/]+\.)?#{view_extensions_pattern}$}
    rails.app_layout  = %r{^#{rails.layouts_dir}/application\.(?:[^/]+\.)?#{view_extensions_pattern}$}

    rails.decorators_dir = 'app/decorators'
    rails.decorators     = %r{^#{rails.decorators_dir}/([^_]+)_.+\.rb$}

    rails.helpers_dir = 'app/helpers'
    rails.helpers     = %r{^{rails.helpers_dir}/(.+)_helper\.rb}
    ####################################################

    ##### Watch files ##################################
    ## watch Ruby files ##
    dsl.watch_spec_files_for(ruby.lib_files)

    # watch RSpec config
    watch(rspec.spec_helper)  { rspec.spec_dir }
    watch(rspec.spec_support) { rspec.spec_dir }

    # watch spec files
    ## run with directory
    watch(rspec.models_concerns)       { rspec.models_dir }
    watch(rspec.features_applications) { rspec.features_dir }

    ## run with file
    watch(rspec.spec_files)
    watch(rspec.factories) do |m|
      [
        rspec.spec.call("models/#{m[1].singularize}"),
        rspec.feature_spec.call("features/#{m[1].pluralize}"),
      ]
    end

    # watch Rails config
    watch(rails.spec_helper) { rspec.spec_dir }

    # wach Rails app files
    ## run with directory
    watch(rails.models_concerns)      { rspec.models_dir }
    watch(rails.rake_tasks)           { rspec.raketask_dir }
    watch(rails.app_layout)           { rspec.features_dir }
    watch(rails.routes)               { [rspec.routing_dir, rspec.features_dir] }
    watch(rails.controllers_concerns) { [rspec.controllers_dir, rspec.features_dir] }
    watch(rails.app_controller)       { [rspec.controllers_dir, rspec.features_dir] }
    watch(rails.decorators)           { [rspec.controllers_dir, rspec.features_dir] }
    watch(rails.helpers)              { [rspec.controllers_dir, rspec.features_dir] }

    ## run with file
    dsl.watch_spec_files_for(rails.app_files)
    dsl.watch_spec_files_for(rails.views)
    watch(rails.view_dirs) { |m| rspec.spec.call("features/#{m[1]}_controller") }
    watch(rails.layouts)   { |m| rspec.feature_spec.call("features/#{m[1]}_controller") }
    watch(rails.controllers) do |m|
      [
        rspec.spec.call("routing/#{m[1]}_routing"),
        rspec.spec.call("controllers/#{m[1]}_controller"),
        rspec.feature_spec.call("features/#{m[1]}_controllers"),
      ]
    end
    watch(rails.decorators) { |m| rspec.spec.call("models/#{m[1]}") }
  end

  guard :rubocop, cli: '-a' do
    watch('config.ru')
    watch('Gemfile')
    watch('Rakefile')
    watch(/.+\.rb$/)
    watch(/.+\.rake$/)
    watch(%r{(?:.+/)?\.rubocop(_todo)?\.yml$}) { |m| File.dirname(m[0]) }
  end
end
# rubocop:enable Metrics/BlockLength
