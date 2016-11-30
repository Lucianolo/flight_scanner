class LoginController < ApplicationController
    def index
        if params[:user] == "user" && params[:password] == "password"
            session[:id] = 10
            redirect_to home_index_path
        else
            render 'index'
        end
    end
end
