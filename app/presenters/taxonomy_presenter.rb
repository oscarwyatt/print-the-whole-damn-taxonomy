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
  def initialize(tree, homogeneity_scores)
    @taxonomy = tree
    @width = 0
    @height = 0
    @homogeneity_scores = homogeneity_scores
    @parsed_homogeneity_scores = {}
  end

  def present
    collate_homogeneity_scores
    entries = []
    last_level = 0
    xes = Hash.new(Config.margin)
    parent_coords = Hash.new{|h,k| h[k] = [Config.margin, Config.margin] }
    last_top_level_y = 0
    row_count = 0
    taxonomy.each do |taxonomy_row|
      entry, last_level, xes, parent_coords, last_top_level_y, row_count = RowPresenter.new(taxonomy_row, last_level, xes, parent_coords, last_top_level_y, row_count, @parsed_homogeneity_scores).present
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

  def collate_homogeneity_scores
    all_scores = []
    @homogeneity_scores.each do |row|
      all_scores << row[3].to_f
    end
    all_scores.sort!

    divider = (all_scores.count.to_f / 3.00).ceil
    mid_range_divider = all_scores[divider]
    high_range_divider = all_scores[divider * 2]

    @homogeneity_scores.each do |row|
      taxon_id = row[1]
      cosine_score = row[3].to_f
      if cosine_score < mid_range_divider
        @parsed_homogeneity_scores[taxon_id] = [cosine_score, 0]
      elsif cosine_score >= mid_range_divider && cosine_score < high_range_divider
        @parsed_homogeneity_scores[taxon_id] = [cosine_score, 1]
      else
        @parsed_homogeneity_scores[taxon_id] = [cosine_score, 2]
      end
    end
  end
end


class RowPresenter

  def initialize(row, previous_last_level, previous_xes, parent_coords, last_top_level_y, row_count, parsed_homogeneity_scores)
    @row = row
    @last_level = previous_last_level
    @xes = previous_xes
    @x = 0
    @y = 0
    @text = ""
    @percentage_text = ""
    @homogeneity_text = ""
    @coarseness_text = ""
    @coarseness_colour = neutral_colour
    @percentage_colour = neutral_colour
    @homogeneity_colour = neutral_colour
    @parent_coords = parent_coords
    @parent_x = 0
    @parent_y = 0
    @last_top_level_y = last_top_level_y
    @print_lines = true
    @row_count = row_count
    @parsed_homogeneity_scores = parsed_homogeneity_scores
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

        coarseness_score = row[taxon_level + 6].to_i
        percentage_score = row[taxon_level + 9].to_i
        homogeneity_score = 0

        taxon_content_id = row[taxon_level + 1]
        cosine_data = @parsed_homogeneity_scores[taxon_content_id]
        if cosine_data
          homogeneity_score = cosine_data.second.to_i
          @homogeneity_text = "cosine similarity: #{cosine_data.first.to_f.round(2)}"
          @homogeneity_text += "\ncosine score: #{homogeneity_score}"
        else
          p "no homogeneity data for #{entry}"
        end

        @text += "\n# tagged: #{row[taxon_level + 3].to_i}"
        @text += "\n# tagged + chldrn: #{row[taxon_level + 4].to_i}"
        @text += "\n total score: #{coarseness_score + percentage_score + homogeneity_score}"

        @coarseness_text += "\n# coarseness: #{row[taxon_level + 5].to_i}"
        @coarseness_text += "\n# coarseness score: #{coarseness_score}"

        @percentage_text = "\n% tagged: #{(row[taxon_level + 7])}"
        @percentage_text += "\n% score: #{percentage_score}"

        # Coarseness colour
        coarseness_score = row[taxon_level + 6].to_i
        if coarseness_score == 0
          @coarseness_colour = good_colour
        end
        if coarseness_score == 2
          @coarseness_colour = bad_colour
        end

        # Percentage colour
        percentage_score = row[taxon_level + 9].to_i
        if percentage_score == 0
          @percentage_colour = good_colour
        end
        if percentage_score == 2
          @percentage_colour = bad_colour
        end

        # Cosine colour
        if cosine_data
          if homogeneity_score == 0
            @homogeneity_colour = good_colour
          end
          if homogeneity_score == 2
            @homogeneity_colour = bad_colour
          end
        end

        @parent_x = @parent_coords[taxon_level - 1].first
        @parent_y = @parent_coords[taxon_level - 1].second
        break
      end
    end
    [{ x: @x, y: @y, name: @text, coarseness_text: @coarseness_text,percentage_text: @percentage_text, homogeneity_text: @homogeneity_text, coarseness_colour: @coarseness_colour, percentage_colour: @percentage_colour, homogeneity_colour: @homogeneity_colour, parent_x: @parent_x, parent_y: @parent_y, print_lines: @print_lines }, @last_level, @xes, @parent_coords, @last_top_level_y, @row_count]
  end

  def new_parent_coords
    [@x, @y + Config.y_difference_for_lines * 1.2]
  end

private
  attr_accessor :row

  def bad_colour
    "#A50029"
  end

  def neutral_colour
    "#666666"
  end

  def good_colour
    "#466F99"
  end

end
