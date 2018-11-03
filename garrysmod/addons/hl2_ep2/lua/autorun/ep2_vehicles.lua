
//
// Don't try to edit this file if you're trying to add new vehicles
// Just make a new file and copy the format below.
//

local V = { 	
				// Required information
				Name = "Jalopy", 
				Class = "prop_vehicle_jeep",
				Category = "Half-Life 2",

				// Optional information
				Author = "VALVe",
				Information = "The muscle car from Episode 2",
				Model = "models/vehicle.mdl",
				
				KeyValues = {
								vehiclescript	=	"scripts/vehicles/jalopy.txt"
							}
			}

list.Set( "Vehicles", "Jalopy", V )

