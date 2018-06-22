class App::BuildBroadcastWorker

    include Sidekiq::Worker
    sidekiq_options retry: false, queue: 'cable'

    def perform build_id
        build = App::Build.find build_id
        ActionCable.server.broadcast "app_build_channel", id: build_id, manage: render_manage(build), update: render_update(build)
    end

    private

    def render_manage build
        ApplicationController.renderer.render partial: 'apps/builds/manage', locals: { build: build }
    end

    def render_update build
        ApplicationController.renderer.render partial: 'apps/builds/update', locals: { build: build }
    end

end
