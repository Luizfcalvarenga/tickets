module Admin
  class AdminController < ApplicationController
    def approve_form
      entity_class = params[:entity_class].classify.constantize
      
      raise unless [Event, DayUse, Membership].include?(entity_class)

      @entity = entity_class.find(params[:entity_id])
    end

    def approve
      entity_class = params[:entity_class].classify.constantize
      
      raise unless [Event, DayUse, Membership].include?(entity_class)

      @entity = entity_class.find(params[:entity_id])

      if params[:approve][:fee_percentage].blank?
        flash[:alert] = "Insira alguma taxa"
        redirect_to request.referrer
      else
        update_params = {
          fee_percentage: params[:approve][:fee_percentage].to_f,
          absorb_fee: params[:approve][:absorb_fee].to_i == 1,
          approved_at: Time.current,
          approved_by: current_user
        }
        update_params.merge({allow_installments: params[:approve][:allow_installments].to_i == 1,}) if @entity.respond_to? :allow_installments

        @entity.update(update_params)

        redirect_to dashboard_path_for_user(current_user)
      end
    end
  end
end
