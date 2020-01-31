class Admins::RegistrationsController < Devise::RegistrationsController
  prepend_before_action :require_no_authentication, only: [:cancel]

  def create
    if params[:admin].present?
      admin = Admin.new(admin_params)
      if admin.save
        flash[:notice] = "Admin Signup in successfully!!!"
        redirect_to root_path
      end
    end
  end

  def destroy
    if params[:id].present?
      admin = Admin.find_by(id: params[:id])
      admin.destroy if admin.present?
      redirect_to root_path, notice: "Admin User successfully destroyed!!!"
    else
      redirect_to root_path, notice: "Admin User not found!!!"
    end
  end

  private

  def admin_params
    params.require(:admin).permit(:email, :password, :password_confirmation)
  end

  def after_update_path_for(resource)
    sign_in_after_change_password? ? admins_users_path : new_admin_session_path(resource_name)
  end

end
