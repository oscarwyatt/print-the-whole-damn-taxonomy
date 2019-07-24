class TaxonomyPrintsController < ActionController::Base
  require 'csv'
  before_action :build_tree

  def new; end

  def show
    av= ActionView::Base.new(Rails.root.join('app/views'))

    filename = "Try_not_to_be_an_asshole"
    filename = filename.gsub(/[^\w\.]/, '_')
    filename += ".pdf"


    pdf = render_to_string(pdf: filename,
                            template: 'taxonomy_prints/show.pdf.erb',
                            page_size: "Letter",
                            dpi: '300',
                            encoding: 'utf8',
                            javascript_delay: 5000,
                            page_height: @height_mm,
                            page_width: @width_mm,
                            )
    send_data(pdf, filename: filename, type: "application/pdf")
  end
private
  def build_tree
    tree_csv = CSV.read("tree.csv")
    homogeneity_scores = CSV.read("taxon_homogeneity.csv")
    @tree_presenter = TaxonomyPresenter.new(tree_csv, homogeneity_scores)
    @tree = @tree_presenter.present.to_json
    @height = @tree_presenter.height
    @width = @tree_presenter.width
    @width_mm = @width * 0.2645833333
    @height_mm = @height * 0.2645833333
  end
end
