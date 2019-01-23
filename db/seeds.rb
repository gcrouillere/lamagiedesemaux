puts "Cleaning previous data"
ShippingCategory.destroy_all

puts "Starting seed"

weights = [250, 500, 750, 1000, 2000, 5000, 10000, 30000]


prices = { "METRO": [495, 625, 710, 780, 880, 1335, 1950, 2780],
    "Outre-Mer 1": [945, 945, 1435, 1435, 1950, 2935, 4710, 10500],
    "Outre-Mer 2": [1140, 1140, 1710, 1710, 3010, 5050, 9850, 25000],
    "UE": [1230, 1230, 1520, 1520, 1720, 2200, 3630, 6030],
    "Eastern Europe Norvège and Maghreb": [1665, 1665, 1990, 1990, 2175, 2795, 4625, 7215],
    "Rest of the world": [2435, 2435, 2710, 2710, 3730, 5455, 10310, 16460]
}

known_countries = ["FR", "AD", "MC", "GF", "GP", "MQ", "YT", "MF", "PM", "BL", "WF", "PF", "NC", "TF", "AT", "DE", "BE", "BG", "HR", "CY", "DK", "ES", "EE", "FI", "GR", "HU", "IE", "IT", "LV", "LT", "LU", "MT", "NL", "PL", "PT", "CZ", "RO", "GB", "SK", "SI", "SE", "CH", "LI", "VA", "SM", "DZ", "NO", "MR", "EH", "MA", "TN", "LY", "BY", "BA", "MD", "ME", "AL", "MK"]

countries_classification = {
  "METRO": ["FR", "AD", "MC"],
  "Outre-Mer 1": ["GF", "GP", "MQ", "YT", "MF", "PM", "BL"],
  "Outre-Mer 2": ["WF", "PF", "NC", "TF"],
  "UE": ["AT", "DE", "BE", "BG", "HR", "CY", "DK", "ES", "EE", "FI", "GR", "HU", "IE", "IT", "LV", "LT", "LU", "MT", "NL", "PL", "PT", "CZ", "RO", "GB", "SK", "SI", "SE", "CH", "LI", "VA", "SM"],
  "Eastern Europe Norvège and Maghreb": ["DZ", "NO", "MR", "EH", "MA", "TN", "LY", "BY", "BA", "MD", "ME", "AL", "MK"],
  "Rest of the world": ["ZZ"]
}


area_name = ["METRO", "Outre-Mer 1", "Outre-Mer 2", "UE", "Eastern Europe Norvège and Maghreb", "Rest of the world"]

ISO3166::Country.countries.each do |country|
  weights.each_with_index do |weight, index|
    if known_countries.include? country.alpha2
      countries_classification.each do |k,v|
        if countries_classification[k].include? country.alpha2
          ShippingCategory.create(name: country.name, alpha2: country.alpha2, weight: weight, price_cents: prices[k][index])
        end
      end
    else
      ShippingCategory.create(name: country.name, alpha2: country.alpha2, weight: weight, price_cents: prices[:"Rest of the world"][index])
    end
  end
end
