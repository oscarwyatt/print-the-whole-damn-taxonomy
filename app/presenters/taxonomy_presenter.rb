class Config
  def self.margin
    100
  end

  def self.height_per_row
    300
  end

  def self.width_per_entry
    150
  end

  def self.y_difference_for_lines
    self.height_per_row / 4
  end

end

class TaxonomyPresenter
  attr_accessor :width, :height
  def initialize(tree)
    @taxonomy = tree
    @width = 0
    @height = 0
  end

  def present
    entries = []
    last_level = 0
    xes = Hash.new(Config.margin)
    parent_coords = Hash.new{|h,k| h[k] = [Config.margin, Config.margin] }
    last_top_level_y = 0
    row_count = 0
    taxonomy.each do |taxonomy_row|
      entry, last_level, xes, parent_coords, last_top_level_y, row_count = RowPresenter.new(taxonomy_row, last_level, xes, parent_coords, last_top_level_y, row_count).present
      entries << entry
      if entry[:x] > @width
        @width = entry[:x] + Config.width_per_entry
      end
      if entry[:y] > @height
        @height = entry[:y] + Config.height_per_row + Config.margin
      end
    end
    entries
  end


private
  attr_reader :taxonomy
end


class RowPresenter

  def initialize(row, previous_last_level, previous_xes, parent_coords, last_top_level_y, row_count)
    @row = row
    @last_level = previous_last_level
    @xes = previous_xes
    @x = 0
    @y = 0
    @text = ""
    @percentage_text = ""
    @percentage_text
    @coarseness_colour = "#000"
    @percentage_colour = "#000"
    @parent_coords = parent_coords
    @parent_x = 0
    @parent_y = 0
    @last_top_level_y = last_top_level_y
    @print_lines = true
    @row_count = row_count
  end

  def present
    row.each_with_index do |entry, taxon_level|
      if entry.to_s.length > 0
        @y = (taxon_level * Config.height_per_row) + Config.margin + @last_top_level_y
        if taxon_level > @last_level
          # We've gone down a level
          @x = @xes[taxon_level - 1].dup
          @xes[taxon_level] = @x.dup
          @parent_coords[taxon_level] = new_parent_coords
        elsif taxon_level == @last_level
          # Same level
          @xes[taxon_level] += Config.width_per_entry
          @x = @xes[taxon_level].dup
          @parent_coords[taxon_level] = new_parent_coords

          if taxon_level <= 1
            @y += 1200
            @last_top_level_y += 1200
            @x = Config.margin
            @print_lines = false
            @row_count += 1
          end
        elsif taxon_level < @last_level
          # Gone up a level
          @x = @xes.values.sort.last.dup + Config.width_per_entry
          if taxon_level <= 1
            @y += 1200
            @last_top_level_y += 1200
            @x = Config.margin
            @print_lines = false
            @row_count += 1
          end
          @xes.each_pair do |taxon, x_for_taxon|
            @xes[taxon] = @x.dup
          end
          @parent_coords[taxon_level] = new_parent_coords
        end
        @last_level = taxon_level.dup
        # to_i as some are nil, which should equate to zero
        @text = entry
        @text += "\n# tagged to it: #{row[taxon_level + 2].to_i}"
        @text += "\n# tagged to it + chldrn: #{row[taxon_level + 3].to_i}"
        @text += "\n# coarseness: #{row[taxon_level + 4].to_i}"
        @text += "\n# coarseness score: #{row[taxon_level + 5].to_i}"

        @percentage_text = "\n# % tagged to level: #{(row[taxon_level + 6])}"
        @percentage_text += "\n# diff to expected %: #{(row[taxon_level + 7].to_f).round(0)}"
        @percentage_text += "\n % score: #{row[taxon_level + 8].to_i}"

        # Coarseness colour
        coarseness_score = row[taxon_level + 5].to_i
        if coarseness_score == 0
          @coarseness_colour = "#009919"
        end
        if coarseness_score == 2
          @coarseness_colour = "#f00"
        end

        # Percentage colour
        percentage_score = row[taxon_level + 8].to_i
        if percentage_score == 0
          @percentage_colour = "#009919"
        end
        if percentage_score == 2
          @percentage_colour = "#f00"
        end

        @parent_x = @parent_coords[taxon_level - 1].first
        @parent_y = @parent_coords[taxon_level - 1].second
        break
      end
    end
    [{ x: @x, y: @y, name: @text, percentage_text: @percentage_text, coarseness_colour: @coarseness_colour, percentage_colour: @percentage_colour, parent_x: @parent_x, parent_y: @parent_y, print_lines: @print_lines }, @last_level, @xes, @parent_coords, @last_top_level_y, @row_count]
  end

  def new_parent_coords
    [@x, @y + Config.y_difference_for_lines / 2]
  end

private
  attr_accessor :row

end
