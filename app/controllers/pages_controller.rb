class PagesController < ApplicationController
  skip_before_action :authenticate_user!, except: [:dashboard, :clean]

  def home
    qrcode = RQRCode::QRCode.new("https://www.lunacali.com")

    @svg = qrcode.as_svg(
      color: "000",
      shape_rendering: "crispEdges",
      module_size: 11,
      standalone: true,
      use_path: true
    )
  end

  def partnership
  end

  def clean
    Read.destroy_all
    Qrcode.destroy_all
    Event.destroy_all
    redirect_to dashboard_path
  end
end
