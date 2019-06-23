package classes.Scenes.Dungeons 
{
import classes.*;
import classes.Scenes.SceneLib;

/**
	 * ...
	 * @author Kitteh6660
	 */

	public class DungeonAbstractContent extends BaseContent
	{
        public static var inDungeon:Boolean = false;

        public static var dungeonLoc:int = 0;

        public static var inRoomedDungeon:Boolean = false;

        public static var inRoomedDungeonResume:Function = null;

        protected function get dungeons():DungeonEngine {
			return SceneLib.dungeons;
		}
		public function DungeonAbstractContent() 
		{	
		}
		public var description:String = ""; //text diplayed when entering the dungeon
		public var name:String = "";	//name of the dungeon
		private var floors:/*DngFloors*/Array = [];	//list of floors
		public function setFloors(Floors:Array):void { 
			floors = Floors;
		};
		public function allFloors():Array {
			return floors;
		}
		//enters the dungeon; also does some checks to verify that dungeon was properly setup
		public function enterDungeon_():void {
			actualRoom = null;
			var Entry:DngRoom = null;
			var Exit:DngRoom = null;
			var Room:DngRoom;
			//search the dungeon-Entry, has to be in first floor
			var rooms:Array = (this.floors[0] as DngFloor).allRooms();
			for (var i:int = 0; i < rooms.length; i++ ) {
				Room = (rooms[i] as DngRoom);
				if (Room.isDungeonEntry) {
					Entry = Room;
				}
				if (Room.isDungeonExit) {
					Exit = Room;
				}
			}
			if (Entry == null || Exit == null) {
				outputText("Error: Dungeon-Exit or Entry missing");//Todo throw error
			}
			dungeonLoc = -1; // not oldschool dungeon
			inDungeon = false;
			inRoomedDungeon = true;
			inRoomedDungeonResume = resumeRoom;
			moveToRoom(Entry);
			playerMenu();
			
		}
		
		public function teleport(Floor:DngFloor, Room:DngRoom) {
			actualRoom = null;
			moveToRoom(Room);
		}
		
		//public function getFloorFromRoom(Room:DngRoom):DngFloor {
		//}
		public var actualRoom:DngRoom = null;
		
		private function moveToRoom(newRoom:DngRoom):void {
			clearOutput();
			statScreenRefresh();
			//DungeonCore.setTopButtons();
			spriteSelect(-1);
			menu();
			var _actualRoom:DngRoom = actualRoom;
			actualRoom = newRoom;
			if (_actualRoom != null) {
				newRoom.moveHere(_actualRoom); //this will trigger onExit/onEnter
			}

			if(!CoC.instance.inCombat) resumeRoom(); //resume after combat done
		}
		private function resumeRoom():void {
			clearOutput();
			statScreenRefresh();
			//setTopButtons();
			spriteSelect(-1);
			menu();
			actualRoom.updateRoom();
			outputText(actualRoom.description);
			
			/*		Menu Layout
			 * 		[ Op1 ]	[ Op2 ]	[ Op3 ]	[ Op4 ]	[More ]
			 * 		[ Up  ]	[  N  ]	[Down ]	[Mast ]	[ Map ]
			 * 		[  W  ]	[  S  ]	[  E  ]	[ Inv ]	[     ]
			 *  
			 */
			var bt:int;
			var btMask:int = 0xE;
			actualRoom.getDirections().forEach( function(element:*, index:int, arr:Array):void {
				var Dir:DngDirection = element as DngDirection;
				if (Dir == null) return;
				bt = Dir.getDirEnum();
				if (bt == DngDirection.DirN) bt = 6;
				else if (bt == DngDirection.DirS) bt = 11;
				else if (bt == DngDirection.DirE) bt = 12;
				else if (bt == DngDirection.DirW) bt = 10;
				else if (bt == DngDirection.StairDown) bt = 7;
				else if (bt == DngDirection.StairUp) bt = 5;
				if(Dir.canExit()) {
					addButton(bt, Dir.name, moveToRoom, Dir.roomB);
				}else {
					addButtonDisabled(bt, Dir.name, Dir.tooltip);
				}
				btMask = btMask ^ (1 >>> bt);
			});
            if (player.lust >= 30) addButton(8, "Masturbate", SceneLib.masturbation.masturbateGo);
            addButton(13, "Inventory", inventory.inventoryMenu).hint("The inventory allows you to use an item.  Be careful as this leaves you open to a counterattack when in combat.");
			//addButton(14, "Map", map.displayMap).hint("View the map of this dungeon.");
			if(actualRoom.isDungeonExit) {
				for (var i:int = 5; i < 15; i++ ) {	//find an empty navigation button for leave
					bt = i;
					if ( ((btMask << i) & 1) == 0) break;
				}
				addButton(bt, "Leave", exitDungeon_, false);
			}
		}
		public function exitDungeon_(byDefeat:Boolean):void {
			clearOutput();
			if (byDefeat) {
				outputText("After your defeat, you somehow turned up back in your camp.");
			}else {
				outputText("You leave the " + this.name + "and walk back towards camp.");
			}
			inDungeon = inRoomedDungeon = false;
			doNext(camp.returnToCampUseOneHour);
		}
	}

	

}