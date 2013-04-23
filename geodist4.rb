#!/usr/bin/ruby -w

require 'rubygems'
require 'fastercsv'

# Dateien über Kommandozeilenargumente definieren
reference_csv = ARGV[0] # CSV-datei mit den Referenzpunkten (id;lat;long;radius)
locations_csv = ARGV[1] # CSV-Datei mit den Locations () (id;lat;long)
output_csv = ARGV[2] # Gewünschter Name der Output-Datei


# Mathematische Funktionen um Distanz zwischen zwei Punkten definieren zu können
# http://codingandweb.blogspot.de/2012/04/calculating-distance-between-two-points.html

def power(num, pow)
  num ** pow
end

def haversine(lat1, long1, lat2, long2)
  dtor = Math::PI/180
  r = 6378.14*1000
 
  rlat1 = lat1 * dtor 
  rlong1 = long1 * dtor 
  rlat2 = lat2 * dtor 
  rlong2 = long2 * dtor 
 
  dlon = rlong1 - rlong2
  dlat = rlat1 - rlat2
 
  a = power(Math::sin(dlat/2), 2) + Math::cos(rlat1) * Math::cos(rlat2) * power(Math::sin(dlon/2), 2)
  c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))
  d = r * c
 
  return d
end

# Referenzpunkte in Array einlesen

references = []
reference_line_counter = 0

FasterCSV.foreach(reference_csv, :quote_char => '"', :col_sep =>';', :row_sep =>:auto) do |row|
  unless reference_line_counter == 0 then
    references.push ("#{row[0]}|#{row[1]}|#{row[2]}|#{row[3]}")
  end
  reference_line_counter += 1
end

puts "#{(reference_line_counter - 1)} Referenzen eingelesen."
puts " "

# Locations einlesen und berechnen, ob sie innerhalb des definierten Radius der einzelnen Referenzpunkte liegen

location_line_counter = 0
reference_to_check = []
reference_result_string = ""
reference_match_counter = 0
reference_shortest_distance = 0
reference_nearest_to_location = ""

FasterCSV.foreach(locations_csv, :quote_char => '"', :col_sep =>';', :row_sep =>:auto) do |row|
  unless location_line_counter == 0 then
    location_id = "#{row[0]}"
    location_lat = "#{row[1]}"
    location_long = "#{row[2]}"
    
    puts " "
    puts "==============================================================================================="
    puts "Prüfe #{location_id} (#{location_name}, Lat #{location_lat}, Long #{location_long})"
    puts " "
    
    references.each do |ref|
      ref_string = "#{ref}"
      reference_to_check = ref_string.split("|")
      reference_to_check_id = reference_to_check[0]
      reference_to_check_lat = reference_to_check[1]
      reference_to_check_long = reference_to_check[2]
      reference_to_check_radius = reference_to_check[3]
      
      puts "---------------------"
      puts "Referenzpunkt #{reference_to_check_id}: Lat #{reference_to_check_lat}, Long #{reference_to_check_long}, Radius #{reference_to_check_radius} m"
      
      distance = (haversine(location_lat.to_f,location_long.to_f,reference_to_check_lat.to_f,reference_to_check_long.to_f)).round
      puts "Distanz zwischen Location und Referenzpunkt: #{distance} m"

      if distance < reference_to_check_radius.to_f then
        puts "#{location_id} (#{location_name}) in Radius von Referenzpunkt #{reference_to_check_id}: true"
        puts " "
        reference_result_string += "true;#{distance};"
        if reference_match_counter == 0 then
          reference_shortest_distance = distance
          reference_nearest_to_location = "#{reference_to_check_id}"
        else
          if distance < reference_shortest_distance then
            reference_shortest_distance = distance
            reference_nearest_to_location = "#{reference_to_check_id}"
          end 
        end
        reference_match_counter += 1
      else
        puts "#{location_id} (#{location_name}) in Radius von Referenzpunkt #{reference_to_check_id}: false"
        puts " "
        reference_result_string += "false;#{distance};"
      end
    end
    
    puts "Location liegt im Radius von #{reference_match_counter} Referenzpunkten"
    unless reference_match_counter == 0 then
      puts "Der am nächsten liegende Referenzpunkt ist #{reference_nearest_to_location} (#{reference_shortest_distance} m)"
    end
    
    reference_result_string = reference_result_string.chop
    
    open(output_csv, 'a') do |f|
      f.puts "#{location_id};#{location_name};#{location_lat};#{location_long};#{reference_match_counter};#{reference_nearest_to_location};#{reference_shortest_distance};#{reference_result_string}"
    end
    reference_result_string = ""
    reference_match_counter = 0
    reference_nearest_to_location = ""
    reference_shortest_distance = 0
  
  else
    reference_id_header = ""
    
    references.each do |ref|
      ref_string = "#{ref}"
      reference_to_check = ref_string.split("|")
      reference_to_check_id = reference_to_check[0]
      reference_id_header += "ref #{reference_to_check[0]};ref #{reference_to_check[0]} distance;"
    end
    reference_id_header = reference_id_header.chop
    
    open(output_csv, 'w') do |f|
      f.puts "id;name;lat;long;ref matches;ref recommendation;ref shortest distance;#{reference_id_header}"
    end
  end
  location_line_counter += 1
end

puts " "
puts "==========================================="
puts "==========================================="
puts " "
puts "Operation abgeschlossen. #{(location_line_counter - 1)} Locations verarbeitet und Ergebnisse in #{output_csv} geschrieben."
