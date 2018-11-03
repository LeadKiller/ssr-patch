
//
// Don't try to edit this file if you're trying to add new stuff
// Just make a new file and copy the format below.
//

local Category = "Half-Life 2"


local V = { 	
				// Required information
				PrintName = "Magnusson", 
				ClassName = "weapon_striderbuster",
				Category = Category,

				// Optional information
				NormalOffset = 32,
				DropToFloor = true,
				Author = "VALVe",
				AdminOnly = false,
				Information = "The strider bustin' Magnusson Device from HL2: Episode 2"
			}

list.Set( "SpawnableEntities", "weapon_striderbuster", V )
