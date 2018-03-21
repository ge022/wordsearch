############################################################
#
#  Name:        William Grishko
#  Assignment:  Word Search
#  Date:        06/07/2017
#  Class:       CIS 283
#  Description: A program that generates a word search puzzle using words from a file
#
############################################################

class Puzzle
  attr_accessor :word_list, :failed_placements

  def initialize(size, word_list)
    @puzzle = []
    @size = size
    @size.times do
      @row = Array.new(size, '.')
      @puzzle << @row
    end
    @word_list = word_list
    @tried_placements = []
    @failed_placements = []
  end

  def get_direction
    case rand(8)
      when 0
        return 'South'
      when 1
        return 'North'
      when 2
        return 'West'
      when 3
        return 'East'
      when 4
        return 'NorthWest'
      when 5
        return 'NorthEast'
      when 6
        return 'SouthWest'
      when 7
        return 'SouthEast'
    end
  end

  def move_location(location, direction)
    case direction
      when 'South'
        return [location[0] + 1, location[1]]
      when 'North'
        return [location[0] - 1, location[1]]
      when 'West'
        return [location[0], location[1] - 1]
      when 'East'
        return [location[0], location[1] + 1]
      when 'NorthWest'
        return [location[0] - 1, location[1] - 1]
      when 'NorthEast'
        return [location[0] - 1, location[1] + 1]
      when 'SouthWest'
        return [location[0] + 1, location[1] - 1]
      when 'SouthEast'
        return [location[0] + 1, location[1] + 1]
    end
  end

  def inbound(location)
    # Check for out of bounds
    if (location[0] < 0 || location[0] > @size - 1) || (location[1] < 0 || location[1] > @size - 1)
      return false
    else
      return true
    end
  end


  def solve

    @word_list.sort_by { |word| word.length }.reverse.each { |word| # Placing words from largest to smallest

      finding_initial_placement = true
      valid_placement = {}
      character_count = 0

      while finding_initial_placement

        # Skip the word if it can not place
        if @tried_placements.length == (@size * @size) * 8
          @failed_placements << word
          @word_list.delete(word)
          @tried_placements.clear
          valid_placement = false
          finding_initial_placement = false
          next
        end

        char = word[character_count]
        starting_location = [rand(@size), rand(@size)]
        direction = get_direction

        # Regenerate a new starting location and direction if the program already checked for them
        tries_count = 0 # Stop generating if no more possible locations
        while @tried_placements.any? { |tried| tried == starting_location || tried == [starting_location, direction] } && (tries_count != (@size * @size) * 8)
          starting_location = [rand(@size), rand(@size)]
          direction = get_direction
          tries_count += 1
        end

        if @puzzle[starting_location[0]][starting_location[1]] == '.' || @puzzle[starting_location[0]][starting_location[1]] == char
          # First character can be placed
          # Store starting location and direction as tried
          @tried_placements << [starting_location, direction]

          # Set the next character's location
          next_location = move_location(starting_location, direction)

          # Check the rest of the characters for placement
          checking = true
          while checking # while there are characters in the word to check for

            character_count += 1
            char = word[character_count] # Check for next character in the word

            if character_count == word.length
              # Checked for all characters in the word, proceed to place word
              valid_placement = [starting_location, direction]
              checking = false
              finding_initial_placement = false
              next
            end

            if !(inbound(next_location) && (@puzzle[next_location[0]][next_location[1]] == '.' || @puzzle[next_location[0]][next_location[1]] == char))
              # Location invalid, restarting finding_initial_placement
              character_count = 0
              checking = false
              next
            end

            # Moving to next location, for the next character
            next_location = move_location(next_location, direction)

          end

        else
          # Starting location is not valid and stored as tried
          @tried_placements << starting_location
          redo

        end


      end


      if valid_placement != false # If the word can be placed

        # Place first letter
        @puzzle[valid_placement[0][0]][valid_placement[0][1]] = word[0]
        next_location = move_location([valid_placement[0][0], valid_placement[0][1]], valid_placement[1])

        # Place the rest of the word
        character_count = 1
        while character_count != word.length
          @puzzle[next_location[0]][next_location[1]] = word[character_count] # Place next letter in word
          next_location = move_location([next_location[0], next_location[1]], valid_placement[1])
          character_count += 1
        end

      end

    }

  end


  def to_s(scramble)
    characters = []
    @word_list.each { |word|
      word.scan(/\w/).each { |char| characters << char if !characters.include?(char) }
    }

    ret_str = ''
    if scramble == true
      # Deep copy the puzzle
      Marshal.load(Marshal.dump(@puzzle)).each { |row|
        row.each_with_index { |col, index|
          if col == '.'
            row[index] = characters.sample
          end
        }
        ret_str += row.join(' ') + "\n"
      }
    else
      @puzzle.each { |row| ret_str += row.join(' ') + "\n" }
    end
    return ret_str
  end


end