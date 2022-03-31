require "bundler/setup"
require "prawn"
require "prawn/measurement_extensions" # for using .in and .pt
require "prawn/table"

def generate_pdf(params)
  ReportPdf.new(params).render
end

class ReportPdf < Prawn::Document
  # Layout
  MARGIN = 72.pt
  BOTTOM_MARGIN = 40.pt
  FOOTER_HEIGHT = 25.pt
  # Colors
  BLACK = "000000"
  WHITE = "FFFFFF"
  OFFWHITE = "A0A0A0"
  GREY = "888888"
  BRAND_BLUE = "2F5496"

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
    canvas do
      fill_color WHITE
      fill_rectangle [bounds.left, bounds.top], bounds.right, bounds.top
    end
    move_down 90.pt
    text "Title: #{@params[:title]}", align: :center, size: 18.pt, leading: 4.pt, color: BLACK
    text "Brief Description: #{@params[:brief_description]}", align: :center, size: 18.pt, leading: 4.pt, color: BLACK
    text "Description: #{@params[:description]}", align: :center, size: 18.pt, leading: 4.pt, color: BLACK
    text "ID: #{@params[:id]}", align: :center, size: 18.pt, leading: 4.pt, color: BLACK
    text "Status: #{@params[:status]}", align: :center, size: 18.pt, leading: 4.pt, color: BLACK
    text "Last Update: #{@params[:last_updated]}", align: :center, size: 18.pt, leading: 4.pt, color: BLACK
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
