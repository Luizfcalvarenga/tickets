class QrcodesController < ApplicationController
  def show
    @qrcode = Qrcode.find(params[:id])
  end

  def read
    @qrcode = Qrcode.find(params[:id])

    result = !@qrcode.reads.exists?

    @read = Read.create(
      qrcode: @qrcode,
      result: result
    )
    @reads = @qrcode.reads
  end
end
