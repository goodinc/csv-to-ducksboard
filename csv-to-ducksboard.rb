#!/usr/bin/env ruby

require 'date'
require 'csv'
require 'patron'

class DucksboardTimeline
  def initialize(api_key, widget_id)
    @api_key = api_key
    @widget_id = widget_id
    @data = []
  end

  def <<(data_point)
    @data << data_point
  end

  def reset
    response = new_session.delete("/values/#{@widget_id}")
    if response.status != 200
      puts "Ducksboard returned a failure on deleting existing values: #{response.inspect}"
      exit
    end
  end

  def save
    data_str = '['
    data_str += @data.map{ |d| "{ \"timestamp\": #{d[:timestamp].strftime("%s")}, \"value\": #{d[:value]} }" }.join(',') 
    data_str += ']'

    response = new_session.post("/values/#{@widget_id}", data_str)
    if response.status != 200
      puts "Ducksboard returned a failure on posting new values: #{response.inspect}"
      exit
    end
  end

  private

  def new_session
    sess = Patron::Session.new
    sess.base_url = "https://push.ducksboard.com/"
    sess.username = @api_key
    sess.password = "x"
    return sess
  end
end

class CSVToDucksboardApp
  COLUMN_TYPES = [ :datetime, :value ]
  def initialize
    @options = { :api_key => nil,
                 :widget_id => nil,
                 :columns => nil,
                 :num_header_rows => 0,
                 :num_footer_rows => 0,
                 :reset_widget_first => false,
                 :filename => nil }
    @values = []
  end

  def run(argv)
    raise ArgumentError.new('Not all required options given') if !handle_args(argv)
    read_csv_file
    upload_to_ducksboard
  end

  def show_usage
    puts "usage: #{__FILE__} <options> <filename.csv>"

    puts "\nRequired:"
    puts "\t--api-key <API KEY>"
    puts "\t--widget-id <WIDGET ID>"
    puts "\t--column <COLUMN 1 TYPE> [--column <COLUMN 2 TYPE>]"

    puts "\nOptional:"
    puts "\t--num-header-rows <NUM>\t\tDefault is 0"
    puts "\t--num-footer-rows <NUM>\t\tDefault is 0"
    puts "\t--reset-widget-first\t\tDefault is to just update without reset"
  end

  private

  def handle_args(argv)
    while argv.any?
      case (cur_arg = argv.shift)
        when "--api-key"
          raise ArgumentError.new('--api-key requires a value') if !(next_arg = argv.shift)
          @options[:api_key] = next_arg
        when "--widget-id"
          raise ArgumentError.new('--widget-id requires a value') if !(next_arg = argv.shift)
          @options[:widget_id] = next_arg
        when "--column"
          raise ArgumentError.new('--column requires a column type') if !(next_arg = argv.shift)
          @options[:columns] = @options[:columns] || [ ]
          column_type = next_arg.to_sym
          raise ArgumentError.new("#{next_arg} is not a valid column type: #{COLUMN_TYPES.join(', ')}") if !COLUMN_TYPES.include?(column_type)
          @options[:columns] << column_type
        when "--num-header-rows"
          raise ArgumentError.new('--num-header-rows requires a value') if !(next_arg = argv.shift)
          @options[:num_header_rows] = next_arg.to_i
        when "--num-footer-rows"
          raise ArgumentError.new('--num-footerer-rows requires a value') if !(next_arg = argv.shift)
          @options[:num_footer_rows] = next_arg.to_i
        when "--reset-widget-first"
          @options[:reset_widget_first] = true
        else
          raise ArgumentError.new('filename must be the last option') if argv.any?  # if last, assume filename; else problem
          @options[:filename] = cur_arg
      end
    end

    return options_are_valid
  end

  def options_are_valid
    return ( @options[:api_key] && @options[:widget_id] && @options[:columns] && @options[:filename] )
  end

  def read_csv_file
    @values = CSV.read(@options[:filename])
    1.upto(@options[:num_header_rows]) { @values.shift }
    1.upto(@options[:num_footer_rows]) { @values.pop }
  end

  def upload_to_ducksboard
    raise ArgumentError.new('only two-column (datetime, value) data supported so far') if @options[:columns] != [:datetime, :value]
    timeline = DucksboardTimeline.new(@options[:api_key], @options[:widget_id])

    @values.each do |row|
      time_components = row[0].split(/[^0-9]/).map{ |x| x.to_i }
      timestamp = DateTime.new( *time_components )
      feature_usage_val = row[1].to_i
    
      timeline << {:timestamp => timestamp, :value => feature_usage_val}
    end

    timeline.reset if @options[:reset_widget_first]
    timeline.save
  end

end

app = CSVToDucksboardApp.new
#begin
  app.run(ARGV)
#rescue ArgumentError => e
#  puts e.message
#  app.show_usage
#  exit
#end

