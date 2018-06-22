class UsersController < ApplicationController

    before_action :set_user

    def show
        authorize! :read, @user
        turbolinks_animate 'fadein'
        @apps = @user.apps.where(visibility: 'public').order('updated_at desc')
    end

    private

    def set_user
        @user = User.friendly.find params[:id]
    end

end
