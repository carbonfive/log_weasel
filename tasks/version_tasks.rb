# frozen_string_literal: true

require "stitch_fix/y/tasks"

module StitchFix
  module LogWeasel
    module VersionTask
      class << self
        def new(gemspec)
          StitchFix::Y::VersionTask.new(gemspec, bumper_class: NpmAndRubyGemsBumper)
        end

        # Custom class to bump version number in package.json
        class NpmAndRubyGemsBumper < StitchFix::Y::VersionTask::RubyGemsBumper
          def bump(gemspec, task, &block)
            bump_package_json(block)
            commit_package_json
            super
          end

          def bump_package_json(block)
            major, minor, bugfix = package_json_version.split(/\./)
            major, minor, bugfix = block.call(major, minor, bugfix)

            package_json_file = "package.json"
            package_json = JSON.parse(File.read(package_json_file))
            package_json["version"] = [major, minor, bugfix].join(".")

            File.open("package.json", "w") do |file|
              file.puts JSON.generate(
                package_json,
                indent: "  ",
                space: " ",
                object_nl: "\n",
                array_nl: "\n"
              )
            end
          end

          def commit_package_json
            Rake.sh "git add package.json" do |ok, _|
              raise "ERROR: Problem staging updated package.json with new version number" unless ok
            end

            Rake.sh "git commit -m 'Bumping npm package to version #{package_json_version}'" do |ok, _error|
              raise "ERROR: Problem committing package.json with new version number to git" unless ok
            end
          end

          def package_json_version
            package_json_file = "package.json"
            package_json = JSON.parse(File.read(package_json_file))
            package_json["version"]
          end
        end
      end
    end
  end
end
