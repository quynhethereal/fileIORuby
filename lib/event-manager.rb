require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'


def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end


def save_thank_you_letter(id,personal_letter)
  Dir.mkdir("output") unless Dir.exist?("output")
  filename = "output/thanks_#{id}.html"
  File.open(filename,"w") do |file|
    file.puts(personal_letter)
  end

end

def legislators_by_zipcode(zipcode)

  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'  

  begin
    legislators = civic_info.representative_info_by_address(
    address: zipcode,
    levels: 'country',
    roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials

  legislators_name = legislators.map(&:name)
  legislators_name = legislators_name.join(",")

  rescue 
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end

end


# given an array, return a hashmap consisting of the frequency of the elem in array
def convert_array_to_frequency_hashmap(array)
  hash_map = Hash.new(0)
  array.each do |element|
    hash_map[element] +=1
  end
  return hash_map
end

#given an array, return the key that has the maximum values
def return_max_in_hash(array)
  hash = convert_array_to_frequency_hashmap(array)
  return hash.max_by{ |k,v| v}[0]
end

# utility function to convert int -> weekday string as wday returns int
days = {0 => "Sunday",
  1 => "Monday", 
  2 => "Tuesday",
  3 => "Wednesday",
  4 => "Thursday",
  5 => "Friday",
  6 => "Saturday"}


template_letter = File.read("form_letter.erb")
erb_template = ERB.new template_letter

hour_array = Array.new
day_array = Array.new

contents = CSV.open('event_attendees.csv', headers: true, header_converters: :symbol)
contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  
  legislators = legislators_by_zipcode(zipcode)
  

  # personal_letter = erb_template.result(binding)
  # save_thank_you_letter(id,personal_letter)


  time = DateTime.strptime(row[1],"%m/%d/%y %H:%M")
  hour_array.push(time.hour)
  day_array.push(time.wday)

end




printf("The most active hour is %d \n", return_max_in_hash(hour_array))
most_active_wday = return_max_in_hash(day_array)
printf("The most active day of the week is  %s",days[most_active_wday])




