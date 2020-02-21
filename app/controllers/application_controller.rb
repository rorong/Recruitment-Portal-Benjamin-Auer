class ApplicationController < ActionController::Base
  respond_to :html, :json
  include ApplicationHelper
  def after_sign_in_path_for(resource)
    if resource.present? && current_admin.present?
      admins_users_path
    else
      user_dashboard_path
    end
  end
end
