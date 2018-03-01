class UsersController < ApplicationController
  skip_before_action :authenticate_user!, only: [:subscribe]

  def show
    @user = current_user
  end

  def update
    @user = current_user
    @user.update(user_params)
    redirect_to request.referrer
  end

  def subscribe
    unless session[:email]
      if Regexp.new('\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]{2,}\z').match(params[:user][:email]) && params[:user][:first_name] != "" && params[:user][:tracking] != ""
        @user = User.create(subscribe_params)
        if request.referrer.match("contact")
          SubscribeMailer.web_message(@user, @admin).deliver_now
        else
          SubscribeMailer.subscribe(@user, @admin).deliver_now
        end
        @user.destroy
        session[:email] = params[:user][:email]
        flash[:notice] = "Merci pour votre message"
        redirect_to request.referrer
      else
        flash[:alert] = "Les champs ne sont pas remplis correctement"
        redirect_to request.referrer
      end
    end
  end

  private

   def user_params
    params.require(:user).permit(
      :id,
      :first_name,
      :last_name,
      :email,
      :adress,
      :zip_code,
      :city,
      :provider,
      :tracking,
      :uid,
      :facebook_picture_url,
      :token,
      :token_expiry,
      :productphoto,
      :avatarphoto,
      :cityphoto,
      :productphotomobile,
      :lessonphoto,
      :logophoto,
      :darktheme1photo,
      :darktheme2photo,
      :darktheme3photo,
      :darktheme4photo,
      homerightphotos: []
    )
  end

  def subscribe_params
    params.require(:user).permit(:email, :first_name, :tracking, last_name: "Doe")
  end

end
