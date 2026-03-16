class UsersController < ApplicationController
  before_action :set_user_with_associations, only: %i[ show ]
  before_action :set_user, only: %i[ edit update ]

  # GET /users/1
  def show
  end

  # GET /users/1/edit
  def edit
  end

  # PATCH/PUT /users/1
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: "Profilo aggiornato con successo." }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render :edit, status: :unprocessable_entity }
      end
    end
  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    def set_user_with_associations
      @user = User.includes(:sessions).find(params[:id])
    end

    def user_params
      params.require(:user).permit(:nickname, :password, :password_confirmation)
    end
end
