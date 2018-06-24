# frozen_string_literal: true

class AppetizeWorker
  include Sidekiq::Worker
  sidekiq_options(retry: false, queue: 'app')

  def perform(build_id:)
    build = App::Build.find(build_id)
    build.remove_appetize
    build.create_appetize
  end
end
