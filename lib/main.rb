require_relative 'RatesModule'

=begin 
param1 = { 
    key: "bkjIgUhxdghtLw9L", 
    password: "6p8oOccHmDwuJZCyJs44wQ0Iw" 
}

param2 = {
    address_from: {
        zip: "64000",
        country: "MX"
    },
    address_to: {
        zip: "64000",
        country: "MX"
    },
    parcel: {
        length: 10,
        width: 10,
        height: 10,
        distance_unit: "CM",
        weight: 10,
        mass_unit: "KG"
    }
        
} 

pp Rates.get(param1, param2)

=end

