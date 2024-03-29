class API::V1::SessionsController < ApplicationController
  skip_before_action :authorize_request, only: %i[create destroy]
  # before_action :conditionally_authorize_request, only: [:fetch_current_user]

  def create
    user = User.find_by_email(params[:session][:email].strip.downcase)
    if user.nil?
      render json: { errors: ['User not found'] }, status: :not_found
    elsif !user.valid_password?(params[:session][:password])
      render json: { errors: ['Incorrect password'] }, status: :unauthorized
    else # Generate token
      token = user.encode_jwt
      render json: { token:, user: UserSerializer.new(user) }, status: :ok
    end
  end

  def fetch_current_user
    return if !@token && !@current_user && params[:public]

    render json: { token: @token, user: UserSerializer.new(@current_user) }, status: :ok
  end

  def reset_password
    user = User.with_reset_password_token(reset_password_params[:token])

    if user&.reset_password_period_valid?
      if user.reset_password(reset_password_params[:new_password], reset_password_params[:new_password_confirmation])
        if mobile_request?
          render_success(user)
        else
          # Render a simple success message for web clients
          render json: { message: 'Password reset successfully' }, status: :ok
        end
      else
        render_error(user.errors.full_messages)
      end
    else
      render_error(['Token is invalid or expired'])
    end
  end

  def destroy
    session.clear
    render json: { server_message: 'You Logged Out!' }
  end

  def show_reset_password_form
    @token = params[:token]
    render 'api/v1/sessions/reset_password'
  end

  private

  def render_success(user)
    render json: {
      token: user.encode_jwt,
      user: UserSerializer.new(user)
    }, except: :password_digest, status: 200
  end

  def reset_password_params
    params.permit(:token, :new_password, :new_password_confirmation)
  end
end
