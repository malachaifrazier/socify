# Social-Rails is a fork of Socify @sudharti(Sudharsanan Muralidharan)
# Social-Rails is an Open source Social network written in Ruby on Rails.
# @captcussa (Malachai Frazier)
# This file is licensed under GNU GPL v2 or later. See the LICENSE.

class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:complete_profile, :set_password]
  before_action :set_user
  before_action :fetch_photos, only: :show
  before_action :check_ownership, only: [:edit, :update]
  respond_to :html, :js

  include Shared::Photos

  def show
    @activities = PublicActivity::Activity.where(owner: @user).
      order(created_at: :desc).
      paginate(page: params[:page], per_page: 10).uniq
  end

  def update
    if @user.update(user_params)
      respond_to do |format|
        format.html { redirect_to user_path(@user) }
        format.json { head :no_content }
        format.js   {}
      end
    end
  end

  def friends
    @friends = @user.following_users.paginate(page: params[:page])
  end

  def followers
    @followers = @user.user_followers.paginate(page: params[:page])
  end

  def mentionable
    render json: @user.following_users.as_json(only: [:slug, :name]), root: false
  end

  def photo_albums
    @photo_albums = @user.photo_albums.paginate(page: params[:page])
  end

  def set_password
    @user.password              = params[:password]
    @user.password_confirmation = params[:password_confirmation]
    @user.profile_complete      = true
    if @user.save
      sign_in(@user)
      redirect_to root_path
    else
      render :complete_profile
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :bio, :avatar, :cover,
                    :name, :sex, :dob, :location, :phone_number, :avatar_cache,
                    :cover_cache, :email)
  end

  def check_ownership
    redirect_to current_user, notice: 'Not Authorized' unless @user == current_user
  end

  def set_user
    @user = User.friendly.find_by(slug: params[:id])
  end
end
