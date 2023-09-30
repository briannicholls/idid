# frozen_string_literal: true

class Users::PasswordsController < Devise::PasswordsController
  skip_before_action :authorize_request, only: %i[create edit]

  # GET /resource/password/new
  # def new
  #   super
  # end

  # POST /resource/password
  def create
    super do |resource|
      if resource.errors.any?
        # Log or render your custom error message here
        Rails.logger.error(resource.errors.full_messages)
        render json: { errors: resource.errors }, status: 422
      end
    end
  end

  # GET /resource/password/edit?reset_password_token=abcdef
  # def edit
  #   @token = params[:reset_password_token]
  #   if Rails.env.development?
  #     redirect_to "exp://low94oa.nichol88.8080.exp.direct/--/reset-password?token=#{@token}"
  #   else
  #     redirect_to "idid://reset-password?token=#{@token}"
  #   end
  # end

  # PUT /resource/password
  def update
    # Reset the password for the resource (user) by calling reset_password_by_token
    # This will find the user with the provided reset_password_token and update the password
    self.resource = resource_class.reset_password_by_token(resource_params)

    # This yields the resource (user) for further customization if a block is provided
    yield resource if block_given?

    # Check if there are any errors after resetting the password
    if resource.errors.empty?
      # If there are no errors, send a JSON response with a success message
      render json: { message: 'Password reset successfully.' }, status: :ok
    else
      # If there are errors (e.g., invalid token, mismatched passwords), send a JSON response with errors
      render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # protected

  # def after_resetting_password_path_for(resource)
  #   super(resource)
  # end

  # The path used after sending reset password instructions
  # def after_sending_reset_password_instructions_path_for(resource_name)
  #   super(resource_name)
  # end
end
