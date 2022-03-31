require "open-uri"

class PassPdfBuilder
  attr_reader :pass, :document
  
  def initialize(pass)
    @pass = pass
    @document = Prawn::Document.new(margin: [60, 60])
  end
  
  def call
    document.font "Times-Roman"

    table_contents = [
      ["<b><font size='16'>#{@pass.name}</font></b>"],
      @pass.start_time.present? ?  ["<font size='12'><b>Horário: </b> #{@pass.start_time.strftime("%d/%m/%Y %H:%M")} - #{@pass.end_time.strftime("%d/%m/%Y %H:%M")} </font>"] : [""],
      ["<font size='12'><b>Endereço: </b> #{@pass.full_address} </font>"]
    ]

    document.table(table_contents, 
      row_colors: ["A8D1DF"],
      column_widths: 320,
      cell_style: { height: 50, inline_format: true, border_color: "A8D1DF" }, position: :right)
    
    document.move_up 150

    document.image URI.open(@pass.partner.logo.url), width: 150, height: 150

    document.move_down 20

    table_contents = [
      ["<b>Identificação do participante</b>"],
      ["<font size='12'><b>Nome: </b> #{@pass.holder_name} </font>"],
      ["<font size='12'><b>CPF: </b> #{@pass.holder_cpf} </font>"],
    ]

    document.table(table_contents, 
      row_colors: ["dddddd"],
      column_widths: 492,
      cell_style: { height: 40, inline_format: true, border_color: "dddddd", padding: 12 }, position: :center)
    
    document.move_down 20

    document.svg @pass.qrcode_svg, width: 130, height: 130, position: :center

    document.move_down 20

    document.text @pass.identifier, align: :center

    document.move_down 20

    if @pass.related_entity.class === Membership
      document.text "Este passe é pessoal e intrasferível. Não compartilhe esse passe. Entrada mediante documento de identificação com foto.", align: :center
    else
      document.text "Este passe é pessoal e intrasferível. Depois que a entrada for liberada, o passe será cancelado. Não compartilhe esse passe. Entrada mediante documento de identificação com foto.", align: :center
    end

    document.move_down 30

    document.svg @pass.qrcode_svg, width: 100, height: 100, position: :left

    document.move_up 100
    
    document.svg @pass.qrcode_svg, width: 100, height: 100, position: :right

    document.move_up 60

    document.image URI.open("https://res.cloudinary.com/nuflow/image/upload/v1648740319/logo_preta_q88syu.png"), width: 100, height: 100, position: :center

    @document.render_file upload_directory

    pass.pdf_pass.attach(io: File.open(upload_directory), filename: upload_name, content_type: 'application/pdf')
  end

  def upload_directory
    "#{Rails.root}/public/#{upload_name}"
  end

  def upload_name
    "Passe #{pass.name.gsub("/", "-")} - #{pass.holder_name}.pdf"
  end
end
