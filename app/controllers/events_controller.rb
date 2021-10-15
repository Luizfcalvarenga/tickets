
class EventsController < ApplicationController

  def show
    @event = Event.find(params[:id])
    @current_batch = @event.current_batch

    @best_membership_with_discount = @event.membership_events.where(membership_id: current_user.memberships.where(partner: @event.partner)).where("membership_events.discount > ?", 0).order(:discount).last
    @current_price = @best_membership_with_discount.present? && @current_batch.present? ? @current_batch.price * (1 - @best_membership_with_discount.discount) : @current_batch&.price
  end

  def new
    @event = Event.new
    @memberships = current_user.partner.memberships
  end

  def create
    event = Event.new(event_params)
    
    ActiveRecord::Base.transaction do
      if event.save
        create_batch_params.each_with_index do |batch_params, index|
          Batch.create!(event: event, name: batch_params[:name], quantity: batch_params[:quantity], price: batch_params[:price], order: index)
        end
        
        create_membership_events_params.each do |membership_events_params|
          membership = event.partner.memberships.find(membership_events_params[:id])
          free = membership_events_params[:discount].to_s === "100"
          MembershipEvent.create!(
            event: event,
            membership: membership,
            discount: membership_events_params[:discount].to_f/100,
            free: free 
          )
        end
        
        redirect_to dashboard_path_for_user(current_user)
      else
        raise
      end
    end
  end

  def read
    @event = Event.find(params[:id])
    @session = Session.create(user: current_user, event: @event)
  end

  def buy
    event = Event.find(params[:id])

    current_batch = event.current_batch

    raise "Ingressos esgotados" if current_batch.blank? 

    ActiveRecord::Base.transaction do
      qrcode = Qrcode.create(
        user: current_user,
        event: event,
        batch: current_batch,
      )

      if current_batch.qrcodes.length == current_batch.quantity
        current_batch.touch(:ended_at)
      end

      svg_source = RQRCode::QRCode.new(qrcode.identifier).as_svg(
        color: "000",
        shape_rendering: "crispEdges",
        module_size: 5,
        standalone: true,
        use_path: true,
      )

      qrcode.update(svg_source: svg_source)
    end

    redirect_to dashboard_path_for_user(current_user)
  end

  private

  def event_params
    params.require(:event).permit(:name, :description, :photo, :scheduled_start, :scheduled_end)
      .merge(created_by: current_user, partner: current_user.partner)
  end

  def create_batch_params
    params[:batches].select { |batch_params| batch_params[:name].present? || batch_params[:quantity].present? || batch_params[:price].present? } 
  end

  def create_membership_events_params
    params[:memberships]
  end
end
