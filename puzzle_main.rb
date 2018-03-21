############################################################
#
#  Name:        William Grishko
#  Assignment:  Word Search
#  Date:        06/07/2017
#  Class:       CIS 283
#  Description: A program that generates a word search puzzle using words from a file
#
############################################################

require 'prawn'
require 'benchmark'
require_relative 'puzzle.rb'

def print_puzzle(heading, puzzle, scramble)
  text "#{heading}", :align => :center, :size => 24
  move_down 10

  # Print the puzzle
  text puzzle.to_s(scramble), :overflow => :shrink_to_fit, :min_font_size => 1, :align => :center

  move_down 10
  text "Find the following #{puzzle.word_list.length} words:", :align => :center
  move_down 10

  # Print the words to find
  column_box([45, cursor], :columns => 3, :width => bounds.width - 90, :height => 160) do
    puzzle.word_list.each { |word|
      text word
    }
  end
end


print 'Enter the size of your puzzle: '
puzzle_size = gets.to_i
print 'Enter the words file: '
puzzle_words = gets.chomp
print 'How many times to run puzzle for timing: '
times_to_run = gets.to_i

word_list = []

if File.file?(puzzle_words)

  File.open(puzzle_words).each_line { |word|
    word_list << word.chomp.upcase
  }

  time = Benchmark.realtime do

    times_to_run.times do

      puz = Puzzle.new(puzzle_size, word_list)
      puz.solve

      # Output puzzle to PDF
      Prawn::Document.generate "puzzle.pdf" do
        font 'Courier', :size => 10

        print_puzzle('Word Search', puz, true)

        start_new_page

        print_puzzle('Word Search KEY', puz, false)

        # Print words that could not fit
        if !puz.failed_placements.empty?
          move_down 10
          text 'Words that could not fit:', :align => :center
          move_down 10
          column_box([45, cursor], :columns => 3, :width => bounds.width - 90, :height => 160) do
            puz.failed_placements.each { |word|
              text word
            }
          end

        end

      end

    end

  end

  puts "It took an average of #{time / times_to_run} seconds to run the program."


else

  puts 'Puzzle words file not found.'

end
