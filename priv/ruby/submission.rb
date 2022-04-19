require "bundler/setup"
require "prawn"
require "prawn/measurement_extensions" # for using .in and .pt
require "prawn/table"

def generate_pdf(params)
  ReportPdf.new(params).render
end

class ReportPdf < Prawn::Document
  # Layout
  MARGIN = 10.pt
  BOTTOM_MARGIN = 40.pt
  FOOTER_HEIGHT = 25.pt
  # Colors
  BLACK = "000000"
  WHITE = "FFFFFF"
  ORANGE = "FA9441"
  GREY = "CCCCCC"

  def initialize(params)
    Prawn::Fonts::AFM.hide_m17n_warning = true
    @params = params
    super(margin: [MARGIN, MARGIN, BOTTOM_MARGIN + FOOTER_HEIGHT, MARGIN])
    title_page
    define_footer
    number_pages "Page <page> of <total>", {
      start_count_at: 1,
      total_pages: page_count - 1,
      page_filter: ->(pg) { pg > 1 },
      at: [bounds.right - 80, bounds.bottom - 20.pt],
      align: :right,
      size: 10.pt,
      color: GREY
    }
  end

  def title_page
    pad_top(10) { text "#{@params[:challenge_title]}",  align: :left, size: 13.pt, leading: 4.pt, color: BLACK }

    pad_bottom(5) { text "#{@params[:agency_name]}",  align: :left, size: 13.pt, leading: 4.pt, color: BLACK }

    # image "#{@params[:challenge_logo]}", height: 40, position: :right 
    
    stroke do
      line [0, 650], [1000, 650]
      line_width 2
      stroke_color ORANGE
    end

    bounding_box([0, 649], width: 400, height: 150) do
      pad_top(5) { text "Submission Title: ", align: :left, size: 13.pt, leading: 4.pt, color: BLACK }
      text "#{@params[:title]}", align: :left, size: 10.pt, leading: 4.pt, color: BLACK
      pad_top(5) { text "Brief Description: ", align: :left, size: 13.pt, leading: 4.pt, color: BLACK }
      text "#{@params[:brief_description]}", align: :left, size: 10.pt, leading: 4.pt, color: BLACK
    end

    bounding_box([350, 649], width: 150, height: 150) do
      fill_color 'CCCCCC'
      fill { rectangle [1, 150], 400, 151 }
      indent(10) do
        pad_top(10) { text "ID: #{@params[:id]}", align: :left, size: 10.pt, leading: 4.pt, color: BLACK }
        text "Status: #{@params[:status]}", align: :left, size: 10.pt, leading: 4.pt, color: BLACK
        text "Phase: #{@params[:phase]}", align: :left, size: 10.pt, leading: 4.pt, color: BLACK
        text "Submitted On: ", align: :left, size: 10.pt, leading: 4.pt, color: BLACK
        text "#{@params[:submitted_on]}", align: :left, size: 10.pt, leading: 4.pt, color: BLACK
      end
    end

    stroke do
      line [0, 800], [1000, 800]
      stroke_color ORANGE
      horizontal_rule
    end

    pad_top(10) { text "Description: #{@params[:description]}", align: :left, size: 13.pt, leading: 4.pt, color: BLACK }
    text "Uploaded Files: #{@params[:uploaded_file]}", align: :left, size: 13.pt, leading: 4.pt, color: BLACK
    @params[:uploaded_files].each do |file|
      text "#{file}", align: :left, size: 10.pt, leading: 4.pt, color: BLACK 
    end
    text "External URL: #{@params[:external_url]}", align: :left, size: 13.pt, leading: 4.pt, color: BLACK
  end

  #######  PRIVATE!!!
  private
  
  def define_footer
    repeat(->(pg) { pg > 1 }) do
      bounding_box [0, -20.pt], width: bounds.right, height: 25.pt do
        text Time.now.strftime("%m/%d/%Y %H:%M"), size: 10.pt, align: :left, color: GREY
      end
    end
  end
end
