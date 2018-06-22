# frozen_string_literal: true

class BuildError
  def self.process(e, context)
    build = App::Build.find context[:job]['args'][0]
    build.update_attributes status: 'error'
  end
end
