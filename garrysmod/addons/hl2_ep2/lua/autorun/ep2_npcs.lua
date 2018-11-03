
//
// Don't try to edit this file if you're trying to add new NPCs.
// Just make a new file and copy the format below.
//

Category = "Humans + Resistance"

local NPC = { 	Name = "Dr.Magnusson", 
				Class = "npc_magnusson",
				Category = Category	}

list.Set( "NPC", NPC.Class, NPC )



Category = "Zombies + Enemy Aliens"

local NPC = { 	Name = "Zombine", 
				Class = "npc_zombine",
				Category = Category	}

list.Set( "NPC", NPC.Class, NPC )

local NPC = { 	Name = "Antlion Worker", 
				Class = "npc_antlion_worker",
				Category = Category	}

list.Set( "NPC", NPC.Class, NPC )


local NPC = { 	Name = "Antlion Grub", 
				Class = "npc_antlion_grub",
			//	RotateToNormal = true,		// Doesn't work right now..
				Category = Category	}

list.Set( "NPC", NPC.Class, NPC )






Category = "Combine"

local NPC = { 	Name = "Hunter", 
				Class = "npc_hunter",
				Category = Category	}

list.Set( "NPC", NPC.Class, NPC )