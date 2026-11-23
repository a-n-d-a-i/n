package simulation
{
   import editor.Editor_State;
   import editor.edat;
   import flash.utils.ByteArray;
   import math.mathutils;
   import math.vec2;
   import simpleFramework.SimpleInput;
   import simulation.collision.Grid_Edges;
   import simulation.collision.Grid_Entity;
   import simulation.collision.Grid_Segment;
   import simulation.collision.Segment;
   import simulation.collision.Segment_Linear_DoubleSided;
   import simulation.entities.Entity_Base;
   import simulation.entities.Entity_BounceBlock;
   import simulation.entities.Entity_Door_Locked;
   import simulation.entities.Entity_Door_Regular;
   import simulation.entities.Entity_Door_Trap;
   import simulation.entities.Entity_Drone_Chaingun;
   import simulation.entities.Entity_Drone_Chaser;
   import simulation.entities.Entity_Drone_Laser;
   import simulation.entities.Entity_Drone_Zap;
   import simulation.entities.Entity_ExitDoor;
   import simulation.entities.Entity_ExitSwitch;
   import simulation.entities.Entity_FloorGuard;
   import simulation.entities.Entity_Gold;
   import simulation.entities.Entity_Launchpad;
   import simulation.entities.Entity_Mine;
   import simulation.entities.Entity_OnewayPlatform;
   import simulation.entities.Entity_Rocket;
   import simulation.entities.Entity_Thwomp;
   import simulation.entities.Entity_Turret;
   import simulation.inputsource.InputSource_Base;
   import simulation.inputsource.InputSource_Playback;
   import simulation.inputsource.InputSource_Recorder;
   import simulation.ninja.Ninja;
   import tiles.tiledefs;
   import tiles.tiletypes;
   
   public class sim_loader
   {
      
      public static var last_str_loaded:String;
      
      private static const OLDDATA_SEPERATION_CHAR_LEVEL:String = "|";
      
      private static const OLDDATA_SEPERATION_CHAR_OBJECT:String = "!";
      
      private static const OLDDATA_SEPERATION_CHAR_OBJTYPE:String = "^";
      
      private static const OLDDATA_SEPERATION_CHAR_OBJPARAM:String = ",";
      
      private static const OLDDATA_CHAR_PAD:int = 48;
      
      private static const OLDDATA_OBJTYPE_GOLD:int = 0;
      
      private static const OLDDATA_OBJTYPE_BOUNCEBLOCK:int = 1;
      
      private static const OLDDATA_OBJTYPE_LAUNCHPAD:int = 2;
      
      private static const OLDDATA_OBJTYPE_TURRET:int = 3;
      
      private static const OLDDATA_OBJTYPE_FLOORGUARD:int = 4;
      
      private static const OLDDATA_OBJTYPE_PLAYER:int = 5;
      
      private static const OLDDATA_OBJTYPE_DRONE:int = 6;
      
      private static const OLDDATA_OBJTYPE_ONEWAYPLATFORM:int = 7;
      
      private static const OLDDATA_OBJTYPE_THWOMP:int = 8;
      
      private static const OLDDATA_OBJTYPE_TESTDOOR:int = 9;
      
      private static const OLDDATA_OBJTYPE_HOMINGLAUNCHER:int = 10;
      
      private static const OLDDATA_OBJTYPE_EXIT:int = 11;
      
      private static const OLDDATA_OBJTYPE_MINE:int = 12;
      
      public function sim_loader()
      {
         super();
      }
      
      public static function LoadLevel_OldData(param1:Vector.<int>, param2:SimpleInput, param3:ByteArray, param4:int, param5:String) : Simulator
      {
         var _loc15_:InputSource_Base = null;
         mathutils.GenerateNewRandomSeed();
         last_str_loaded = param5;
         var _loc6_:Vector.<int> = new Vector.<int>(Simulator.GRID_NUM_COLS * Simulator.GRID_NUM_ROWS,true);
         var _loc7_:Grid_Segment = new Grid_Segment(Simulator.GRID_NUM_COLS,Simulator.GRID_NUM_ROWS,Simulator.GRID_CELL_SIZE);
         var _loc8_:Grid_Edges = new Grid_Edges(Simulator.GRID_NUM_COLS * 2,Simulator.GRID_NUM_ROWS * 2,Simulator.GRID_CELL_SIZE * 0.5);
         var _loc9_:Grid_Entity = new Grid_Entity(Simulator.GRID_NUM_COLS,Simulator.GRID_NUM_ROWS,Simulator.GRID_CELL_SIZE);
         var _loc10_:Vector.<Entity_Base> = new Vector.<Entity_Base>();
         var _loc11_:Vector.<vec2> = new Vector.<vec2>();
         var _loc12_:Array = param5.split(OLDDATA_SEPERATION_CHAR_LEVEL);
         if(_loc12_.length > 0)
         {
            LoadLevel_OldData_Tiles(_loc12_[0],_loc6_,_loc7_,_loc8_,Simulator.GRID_NUM_COLS,Simulator.GRID_NUM_ROWS,Simulator.GRID_CELL_SIZE,Simulator.GRID_CELL_HALFWIDTH);
         }
         if(_loc12_.length > 1)
         {
            LoadLevel_OldData_Entities(_loc12_[1],_loc7_,_loc8_,_loc9_,_loc10_,_loc11_,Simulator.GRID_CELL_SIZE,Simulator.GRID_CELL_HALFWIDTH);
         }
         if(_loc11_.length == 0)
         {
            trace("WARNING! no player was loaded, default player created");
            _loc11_.push(new vec2(32,32));
         }
         while(_loc11_.length < param4)
         {
            trace("WARNING! forcing ninja creation");
            _loc11_.push(_loc11_[0].Clone());
         }
         while(_loc11_.length > param4)
         {
            _loc11_.pop();
         }
         if(param4 == 2)
         {
            _loc11_[0].x -= 4;
            _loc11_[1].x += 4;
         }
         var _loc13_:Vector.<Ninja> = new Vector.<Ninja>(_loc11_.length,true);
         var _loc14_:int = 0;
         while(_loc14_ < _loc11_.length)
         {
            _loc15_ = new InputSource_Recorder(param2,param1[_loc14_ * 3 % param1.length],param1[(_loc14_ * 3 + 1) % param1.length],param1[(_loc14_ * 3 + 2) % param1.length]);
            _loc13_[_loc14_] = new Ninja(_loc14_,_loc15_,_loc11_[_loc14_].x,_loc11_[_loc14_].y);
            _loc14_++;
         }
         return new Simulator(_loc6_,_loc7_,_loc8_,_loc9_,_loc10_,_loc13_);
      }
      
      public static function LoadLevel_OldData_ARCADE_REPLAY(param1:String, param2:String, param3:String) : Simulator
      {
         last_str_loaded = param3;
         var _loc4_:Vector.<int> = new Vector.<int>(Simulator.GRID_NUM_COLS * Simulator.GRID_NUM_ROWS,true);
         var _loc5_:Grid_Segment = new Grid_Segment(Simulator.GRID_NUM_COLS,Simulator.GRID_NUM_ROWS,Simulator.GRID_CELL_SIZE);
         var _loc6_:Grid_Edges = new Grid_Edges(Simulator.GRID_NUM_COLS * 2,Simulator.GRID_NUM_ROWS * 2,Simulator.GRID_CELL_SIZE * 0.5);
         var _loc7_:Grid_Entity = new Grid_Entity(Simulator.GRID_NUM_COLS,Simulator.GRID_NUM_ROWS,Simulator.GRID_CELL_SIZE);
         var _loc8_:Vector.<Entity_Base> = new Vector.<Entity_Base>();
         var _loc9_:Vector.<vec2> = new Vector.<vec2>();
         var _loc10_:Array = param3.split(OLDDATA_SEPERATION_CHAR_LEVEL);
         if(_loc10_.length > 0)
         {
            LoadLevel_OldData_Tiles(_loc10_[0],_loc4_,_loc5_,_loc6_,Simulator.GRID_NUM_COLS,Simulator.GRID_NUM_ROWS,Simulator.GRID_CELL_SIZE,Simulator.GRID_CELL_HALFWIDTH);
         }
         if(_loc10_.length > 1)
         {
            LoadLevel_OldData_Entities(_loc10_[1],_loc5_,_loc6_,_loc7_,_loc8_,_loc9_,Simulator.GRID_CELL_SIZE,Simulator.GRID_CELL_HALFWIDTH);
         }
         if(_loc9_.length == 0)
         {
            trace("WARNING! no player was loaded, default player created");
            _loc9_.push(new vec2(32,32));
         }
         while(_loc9_.length < 2)
         {
            _loc9_.push(_loc9_[0].Clone());
         }
         _loc9_[0].x -= 4;
         _loc9_[1].x += 4;
         var _loc11_:Vector.<Ninja> = new Vector.<Ninja>(_loc9_.length,true);
         var _loc12_:InputSource_Base = new InputSource_Playback(sim_globals.StringtoBA(param1));
         _loc11_[0] = new Ninja(0,_loc12_,_loc9_[0].x,_loc9_[0].y);
         var _loc13_:InputSource_Base = new InputSource_Playback(sim_globals.StringtoBA(param2));
         _loc11_[1] = new Ninja(1,_loc13_,_loc9_[1].x,_loc9_[1].y);
         return new Simulator(_loc4_,_loc5_,_loc6_,_loc7_,_loc8_,_loc11_);
      }
      
      public static function LoadLevel_OldData_HOLIDAY_REPLAY(param1:String, param2:String) : Simulator
      {
         last_str_loaded = param2;
         var _loc3_:Vector.<int> = new Vector.<int>(Simulator.GRID_NUM_COLS * Simulator.GRID_NUM_ROWS,true);
         var _loc4_:Grid_Segment = new Grid_Segment(Simulator.GRID_NUM_COLS,Simulator.GRID_NUM_ROWS,Simulator.GRID_CELL_SIZE);
         var _loc5_:Grid_Edges = new Grid_Edges(Simulator.GRID_NUM_COLS * 2,Simulator.GRID_NUM_ROWS * 2,Simulator.GRID_CELL_SIZE * 0.5);
         var _loc6_:Grid_Entity = new Grid_Entity(Simulator.GRID_NUM_COLS,Simulator.GRID_NUM_ROWS,Simulator.GRID_CELL_SIZE);
         var _loc7_:Vector.<Entity_Base> = new Vector.<Entity_Base>();
         var _loc8_:Vector.<vec2> = new Vector.<vec2>();
         var _loc9_:Array = param2.split(OLDDATA_SEPERATION_CHAR_LEVEL);
         if(_loc9_.length > 0)
         {
            LoadLevel_OldData_Tiles(_loc9_[0],_loc3_,_loc4_,_loc5_,Simulator.GRID_NUM_COLS,Simulator.GRID_NUM_ROWS,Simulator.GRID_CELL_SIZE,Simulator.GRID_CELL_HALFWIDTH);
         }
         if(_loc9_.length > 1)
         {
            LoadLevel_OldData_Entities(_loc9_[1],_loc4_,_loc5_,_loc6_,_loc7_,_loc8_,Simulator.GRID_CELL_SIZE,Simulator.GRID_CELL_HALFWIDTH);
         }
         var _loc10_:InputSource_Base = new InputSource_Playback(sim_globals.StringtoBA(param1));
         var _loc11_:Vector.<Ninja> = new Vector.<Ninja>(1,true);
         _loc11_[0] = new Ninja(0,_loc10_,_loc8_[0].x,_loc8_[0].y);
         return new Simulator(_loc3_,_loc4_,_loc5_,_loc6_,_loc7_,_loc11_);
      }
      
      private static function LoadLevel_OldData_Entities(param1:String, param2:Grid_Segment, param3:Grid_Edges, param4:Grid_Entity, param5:Vector.<Entity_Base>, param6:Vector.<vec2>, param7:Number, param8:Number) : void
      {
         var _loc11_:Array = null;
         var _loc12_:int = 0;
         var _loc13_:Array = null;
         var _loc14_:Vector.<Number> = null;
         var _loc15_:int = 0;
         param4.Clear();
         param5.length = 0;
         param6.length = 0;
         if(param1.length == 0)
         {
            return;
         }
         var _loc9_:Array = param1.split(OLDDATA_SEPERATION_CHAR_OBJECT);
         var _loc10_:int = 0;
         while(_loc10_ < _loc9_.length)
         {
            _loc11_ = _loc9_[_loc10_].split(OLDDATA_SEPERATION_CHAR_OBJTYPE);
            _loc12_ = Number(_loc11_[0]);
            _loc13_ = _loc11_[1].split(OLDDATA_SEPERATION_CHAR_OBJPARAM);
            _loc14_ = new Vector.<Number>(_loc13_.length,true);
            _loc15_ = 0;
            while(_loc15_ < _loc13_.length)
            {
               _loc14_[_loc15_] = Number(_loc13_[_loc15_]);
               _loc15_++;
            }
            LoadLevel_OldData_CreateEntity(_loc12_,_loc14_,param2,param3,param4,param5,param6,param7,param8);
            _loc10_++;
         }
      }
      
      private static function LoadLevel_OldData_CreateEntity(param1:int, param2:Vector.<Number>, param3:Grid_Segment, param4:Grid_Edges, param5:Grid_Entity, param6:Vector.<Entity_Base>, param7:Vector.<vec2>, param8:Number, param9:Number) : void
      {
         var _loc12_:vec2 = null;
         var _loc13_:Entity_ExitDoor = null;
         var _loc14_:Entity_ExitSwitch = null;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc17_:* = false;
         var _loc18_:int = 0;
         var _loc19_:Vector.<int> = null;
         var _loc20_:vec2 = null;
         var _loc21_:vec2 = null;
         var _loc22_:vec2 = null;
         var _loc23_:Segment_Linear_DoubleSided = null;
         var _loc24_:int = 0;
         var _loc25_:vec2 = null;
         var _loc26_:vec2 = null;
         var _loc10_:Vector.<Entity_Base> = new Vector.<Entity_Base>();
         if(param1 == OLDDATA_OBJTYPE_BOUNCEBLOCK)
         {
            if(param2.length == 2)
            {
               _loc10_.push(new Entity_BounceBlock(param5,param2[0],param2[1]));
            }
         }
         else if(param1 == OLDDATA_OBJTYPE_GOLD)
         {
            if(param2.length == 2)
            {
               _loc10_.push(new Entity_Gold(param5,param2[0],param2[1]));
            }
         }
         else if(param1 == OLDDATA_OBJTYPE_LAUNCHPAD)
         {
            if(param2.length == 4)
            {
               _loc10_.push(new Entity_Launchpad(param5,param2[0],param2[1],param2[2],param2[3]));
            }
         }
         else if(param1 == OLDDATA_OBJTYPE_MINE)
         {
            if(param2.length == 2)
            {
               _loc10_.push(new Entity_Mine(param5,param2[0],param2[1]));
            }
         }
         else if(param1 == OLDDATA_OBJTYPE_ONEWAYPLATFORM)
         {
            if(param2.length == 3)
            {
               _loc12_ = HELPER_OldData_UnpackDirEnum(param2[2]);
               if(_loc12_ != null)
               {
                  _loc10_.push(new Entity_OnewayPlatform(param5,param2[0] + param9 * _loc12_.x,param2[1] + param9 * _loc12_.y,_loc12_.x,_loc12_.y));
               }
            }
         }
         else if(param1 == OLDDATA_OBJTYPE_DRONE)
         {
            if(param2.length == 6)
            {
               if(Boolean(param2[3]))
               {
                  _loc10_.push(new Entity_Drone_Chaser(param5,param2[0],param2[1],param2[5],Math.min(3,param2[2])));
               }
               else if(param2[4] == 0)
               {
                  _loc10_.push(new Entity_Drone_Zap(param5,param2[0],param2[1],param2[5],Math.min(3,param2[2])));
               }
               else if(param2[4] == 1)
               {
                  _loc10_.push(new Entity_Drone_Laser(param5,param2[0],param2[1],param2[5],Math.min(3,param2[2])));
               }
               else if(param2[4] == 2)
               {
                  _loc10_.push(new Entity_Drone_Chaingun(param5,param2[0],param2[1],param2[5],Math.min(3,param2[2])));
               }
            }
         }
         else if(param1 == OLDDATA_OBJTYPE_EXIT)
         {
            if(param2.length == 4)
            {
               _loc13_ = new Entity_ExitDoor(param2[0],param2[1]);
               _loc14_ = new Entity_ExitSwitch(param5,param2[2],param2[3],_loc13_);
               _loc10_.push(_loc13_);
               _loc10_.push(_loc14_);
            }
         }
         else if(param1 == OLDDATA_OBJTYPE_FLOORGUARD)
         {
            if(param2.length == 3)
            {
               _loc10_.push(new Entity_FloorGuard(param5,param2[0],param2[1]));
            }
         }
         else if(param1 == OLDDATA_OBJTYPE_HOMINGLAUNCHER)
         {
            if(param2.length == 2)
            {
               _loc10_.push(new Entity_Rocket(param5,param2[0],param2[1]));
            }
         }
         else if(param1 == OLDDATA_OBJTYPE_TESTDOOR)
         {
            if(param2.length == 9)
            {
               _loc15_ = param2[4] + param2[7];
               _loc16_ = param2[5] + param2[8];
               _loc17_ = param2[2] != 1;
               _loc18_ = param3.DOOR_GetCellIndexFromGridspacePosition(_loc15_,_loc16_);
               _loc19_ = new Vector.<int>(2,true);
               if(!_loc17_)
               {
                  _loc19_[0] = param4.DOOR_GetCellIndexFromGridspacePosition(_loc15_ * 2,_loc16_ * 2 + 1);
                  _loc19_[1] = param4.DOOR_GetCellIndexFromGridspacePosition(_loc15_ * 2 + 1,_loc16_ * 2 + 1);
               }
               else
               {
                  _loc19_[0] = param4.DOOR_GetCellIndexFromGridspacePosition(_loc15_ * 2 + 1,_loc16_ * 2);
                  _loc19_[1] = param4.DOOR_GetCellIndexFromGridspacePosition(_loc15_ * 2 + 1,_loc16_ * 2 + 1);
               }
               _loc20_ = param3.DEBUG_GetWorldspaceCellCenterPositionFromIndex(_loc18_);
               _loc21_ = new vec2(0,0);
               _loc22_ = new vec2(0,0);
               if(_loc17_)
               {
                  _loc21_.x = _loc20_.x + 12;
                  _loc21_.y = _loc20_.y + 12;
                  _loc22_.x = _loc20_.x + 12;
                  _loc22_.y = _loc20_.y - 12;
               }
               else
               {
                  _loc21_.x = _loc20_.x - 12;
                  _loc21_.y = _loc20_.y + 12;
                  _loc22_.x = _loc20_.x + 12;
                  _loc22_.y = _loc20_.y + 12;
               }
               _loc23_ = new Segment_Linear_DoubleSided(_loc21_.x,_loc21_.y,_loc22_.x,_loc22_.y);
               _loc24_ = 0;
               if(Boolean(param2[3]))
               {
                  _loc24_ = 2;
               }
               else if(Boolean(param2[6]))
               {
                  _loc24_ = 1;
               }
               _loc25_ = new vec2(0,0);
               if(_loc24_ == 0)
               {
                  _loc25_.x = 0.5 * (_loc21_.x + _loc22_.x);
                  _loc25_.y = 0.5 * (_loc21_.y + _loc22_.y);
               }
               else
               {
                  _loc25_.x = param2[0];
                  _loc25_.y = param2[1];
               }
               if(_loc24_ == 0)
               {
                  _loc10_.push(new Entity_Door_Regular(param5,param3,_loc18_,_loc23_,param4,_loc19_,_loc17_,_loc25_.x,_loc25_.y));
               }
               else if(_loc24_ == 1)
               {
                  _loc10_.push(new Entity_Door_Locked(param5,param3,_loc18_,_loc23_,param4,_loc19_,_loc17_,_loc25_.x,_loc25_.y));
               }
               else if(_loc24_ == 2)
               {
                  _loc10_.push(new Entity_Door_Trap(param5,param3,_loc18_,_loc23_,param4,_loc19_,_loc17_,_loc25_.x,_loc25_.y));
               }
            }
         }
         else if(param1 == OLDDATA_OBJTYPE_THWOMP)
         {
            if(param2.length == 3)
            {
               _loc26_ = HELPER_OldData_UnpackDirEnum(param2[2]);
               if(_loc26_ != null)
               {
                  if(_loc26_.y == 0)
                  {
                     _loc10_.push(new Entity_Thwomp(param5,param2[0],param2[1],_loc26_.x,true));
                  }
                  else
                  {
                     _loc10_.push(new Entity_Thwomp(param5,param2[0],param2[1],_loc26_.y,false));
                  }
               }
            }
         }
         else if(param1 == OLDDATA_OBJTYPE_TURRET)
         {
            if(param2.length == 2)
            {
               _loc10_.push(new Entity_Turret(param5,param2[0],param2[1]));
            }
         }
         else if(param1 == OLDDATA_OBJTYPE_PLAYER)
         {
            if(param2.length == 2)
            {
               param7.push(new vec2(param2[0],param2[1]));
            }
         }
         var _loc11_:int = 0;
         while(_loc11_ < _loc10_.length)
         {
            Helper_RegisterEntity(param6,_loc10_[_loc11_]);
            _loc11_++;
         }
      }
      
      private static function Helper_RegisterEntity(param1:Vector.<Entity_Base>, param2:Entity_Base) : void
      {
         param2.GAME_SetUID(param1.length);
         param1.push(param2);
      }
      
      private static function HELPER_OldData_UnpackDirEnum(param1:Number) : vec2
      {
         if(param1 == 0)
         {
            return new vec2(1,0);
         }
         if(param1 == 1)
         {
            return new vec2(0,1);
         }
         if(param1 == 2)
         {
            return new vec2(-1,0);
         }
         if(param1 == 3)
         {
            return new vec2(0,-1);
         }
         return null;
      }
      
      private static function LoadLevel_OldData_Tiles(param1:String, param2:Vector.<int>, param3:Grid_Segment, param4:Grid_Edges, param5:int, param6:int, param7:Number, param8:Number) : void
      {
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:String = null;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc17_:int = 0;
         param3.Clear();
         param4.Clear();
         LoadLevel_InitTileIDGridWithBoundaryEdges(param2,param5,param6);
         var _loc9_:int = 0;
         while(_loc9_ < param1.length)
         {
            _loc12_ = 1 + _loc9_ % (param6 - 2);
            _loc13_ = 1 + Math.floor(_loc9_ / (param6 - 2));
            _loc14_ = param1.charAt(_loc9_);
            _loc15_ = _loc14_.charCodeAt(0) - OLDDATA_CHAR_PAD;
            param2[_loc13_ + _loc12_ * param5] = tiletypes.GetTypeFromChar(_loc15_);
            _loc9_++;
         }
         var _loc10_:Vector.<int> = new Vector.<int>(4,true);
         var _loc11_:int = 0;
         while(_loc11_ < param2.length)
         {
            _loc16_ = _loc11_ % param5;
            _loc17_ = Math.floor(_loc11_ / param5);
            if(_loc16_ == 0)
            {
               _loc10_[0] = tiletypes.EMPTY;
            }
            else
            {
               _loc10_[0] = param2[_loc16_ - 1 + _loc17_ * param5];
            }
            if(_loc16_ == param5 - 1)
            {
               _loc10_[2] = tiletypes.EMPTY;
            }
            else
            {
               _loc10_[2] = param2[_loc16_ + 1 + _loc17_ * param5];
            }
            if(_loc17_ == 0)
            {
               _loc10_[3] = tiletypes.EMPTY;
            }
            else
            {
               _loc10_[3] = param2[_loc16_ + (_loc17_ - 1) * param5];
            }
            if(_loc17_ == param6 - 1)
            {
               _loc10_[1] = tiletypes.EMPTY;
            }
            else
            {
               _loc10_[1] = param2[_loc16_ + (_loc17_ + 1) * param5];
            }
            LoadLevel_BuildTileSegs(param3,param7,param8,_loc16_,_loc17_,param2[_loc11_],_loc10_);
            LoadLevel_BuildTileEdges(param4,_loc16_,_loc17_,param2[_loc11_]);
            _loc11_++;
         }
      }
      
      private static function LoadLevel_BuildTileSegs(param1:Grid_Segment, param2:Number, param3:Number, param4:int, param5:int, param6:int, param7:Vector.<int>) : void
      {
         var _loc8_:Vector.<Segment> = tiledefs.GenerateTileSegments_Filtered(param6,param7,param4 * param2 + param3,param5 * param2 + param3,param3);
         var _loc9_:int = 0;
         while(_loc9_ < _loc8_.length)
         {
            param1.AddSegToCell(param4,param5,_loc8_[_loc9_]);
            _loc9_++;
         }
      }
      
      private static function LoadLevel_BuildTileEdges(param1:Grid_Edges, param2:int, param3:int, param4:int) : void
      {
         param1.GAME_LoadTileEdges(param2,param3,param4);
      }
      
      private static function LoadLevel_InitTileIDGridWithBoundaryEdges(param1:Vector.<int>, param2:int, param3:int) : void
      {
         var _loc4_:int = param2 * param3;
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            param1[_loc5_] = tiletypes.EMPTY;
            _loc5_++;
         }
         var _loc6_:int = 1;
         while(_loc6_ < param2 - 1)
         {
            param1[_loc6_] = tiletypes.EDGE_BOTTOM;
            param1[_loc6_ + (param3 - 1) * param2] = tiletypes.EDGE_TOP;
            _loc6_++;
         }
         var _loc7_:int = 1;
         while(_loc7_ < param3 - 1)
         {
            param1[_loc7_ * param2] = tiletypes.EDGE_RIGHT;
            param1[param2 - 1 + _loc7_ * param2] = tiletypes.EDGE_LEFT;
            _loc7_++;
         }
         param1[0] = tiletypes.EDGE_CORNER_UL;
         param1[param2 - 1] = tiletypes.EDGE_CORNER_UR;
         param1[(param3 - 1) * param2] = tiletypes.EDGE_CORNER_DL;
         param1[param3 * param2 - 1] = tiletypes.EDGE_CORNER_DR;
      }
      
      public static function LoadLevel_EditorState(param1:Vector.<int>, param2:Array, param3:SimpleInput, param4:ByteArray, param5:int, param6:Editor_State) : Simulator
      {
         var _loc15_:InputSource_Base = null;
         mathutils.GenerateNewRandomSeed();
         var _loc7_:Vector.<int> = new Vector.<int>(Simulator.GRID_NUM_COLS * Simulator.GRID_NUM_ROWS,true);
         var _loc8_:Grid_Segment = new Grid_Segment(Simulator.GRID_NUM_COLS,Simulator.GRID_NUM_ROWS,Simulator.GRID_CELL_SIZE);
         var _loc9_:Grid_Edges = new Grid_Edges(Simulator.GRID_NUM_COLS * 2,Simulator.GRID_NUM_ROWS * 2,Simulator.GRID_CELL_SIZE * 0.5);
         var _loc10_:Grid_Entity = new Grid_Entity(Simulator.GRID_NUM_COLS,Simulator.GRID_NUM_ROWS,Simulator.GRID_CELL_SIZE);
         var _loc11_:Vector.<Entity_Base> = new Vector.<Entity_Base>();
         var _loc12_:Vector.<vec2> = new Vector.<vec2>();
         LoadLevel_EditorState_Tiles(param6.tileIDs,_loc7_,_loc8_,_loc9_,Simulator.GRID_NUM_COLS,Simulator.GRID_NUM_ROWS,Simulator.GRID_CELL_SIZE,Simulator.GRID_CELL_HALFWIDTH);
         LoadLevel_EditorState_Entities(param6.entities,_loc8_,_loc9_,_loc10_,_loc11_,_loc12_,Simulator.GRID_CELL_SIZE,Simulator.GRID_CELL_HALFWIDTH);
         if(_loc12_.length == 0)
         {
            trace("WARNING! no player was loaded, default player created");
            _loc12_.push(new vec2(32,32));
         }
         while(_loc12_.length < param5)
         {
            trace("WARNING! forcing ninja creation");
            _loc12_.push(_loc12_[0].Clone());
         }
         while(_loc12_.length > param5)
         {
            _loc12_.pop();
         }
         if(_loc12_.length == 2)
         {
            _loc12_[0].x -= 4;
            _loc12_[1].x += 4;
         }
         var _loc13_:Vector.<Ninja> = new Vector.<Ninja>(_loc12_.length,true);
         var _loc14_:int = 0;
         while(_loc14_ < _loc12_.length)
         {
            _loc15_ = null;
            if(param4 == null)
            {
               _loc15_ = new InputSource_Recorder(param3,param1[_loc14_ * 3 % param1.length],param1[(_loc14_ * 3 + 1) % param1.length],param1[(_loc14_ * 3 + 2) % param1.length]);
            }
            else
            {
               _loc15_ = new InputSource_Playback(param4);
            }
            _loc13_[_loc14_] = new Ninja(_loc14_,_loc15_,_loc12_[_loc14_].x,_loc12_[_loc14_].y,param2[_loc14_]);
            _loc14_++;
         }
         return new Simulator(_loc7_,_loc8_,_loc9_,_loc10_,_loc11_,_loc13_);
      }
      
      private static function LoadLevel_EditorState_Tiles(param1:Vector.<uint>, param2:Vector.<int>, param3:Grid_Segment, param4:Grid_Edges, param5:int, param6:int, param7:Number, param8:Number) : void
      {
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         param3.Clear();
         param4.Clear();
         LoadLevel_InitTileIDGridWithBoundaryEdges(param2,param5,param6);
         var _loc9_:int = 0;
         while(_loc9_ < param1.length)
         {
            _loc12_ = 1 + _loc9_ % edat.num_cols;
            _loc13_ = 1 + Math.floor(_loc9_ / edat.num_cols);
            param2[_loc12_ + _loc13_ * param5] = param1[_loc9_];
            _loc9_++;
         }
         var _loc10_:Vector.<int> = new Vector.<int>(4,true);
         var _loc11_:int = 0;
         while(_loc11_ < param2.length)
         {
            _loc14_ = _loc11_ % param5;
            _loc15_ = Math.floor(_loc11_ / param5);
            if(_loc14_ == 0)
            {
               _loc10_[0] = tiletypes.EMPTY;
            }
            else
            {
               _loc10_[0] = param2[_loc14_ - 1 + _loc15_ * param5];
            }
            if(_loc14_ == param5 - 1)
            {
               _loc10_[2] = tiletypes.EMPTY;
            }
            else
            {
               _loc10_[2] = param2[_loc14_ + 1 + _loc15_ * param5];
            }
            if(_loc15_ == 0)
            {
               _loc10_[3] = tiletypes.EMPTY;
            }
            else
            {
               _loc10_[3] = param2[_loc14_ + (_loc15_ - 1) * param5];
            }
            if(_loc15_ == param6 - 1)
            {
               _loc10_[1] = tiletypes.EMPTY;
            }
            else
            {
               _loc10_[1] = param2[_loc14_ + (_loc15_ + 1) * param5];
            }
            LoadLevel_BuildTileSegs(param3,param7,param8,_loc14_,_loc15_,param2[_loc11_],_loc10_);
            LoadLevel_BuildTileEdges(param4,_loc14_,_loc15_,param2[_loc11_]);
            _loc11_++;
         }
      }
      
      private static function LoadLevel_EditorState_Entities(param1:Vector.<Vector.<uint>>, param2:Grid_Segment, param3:Grid_Edges, param4:Grid_Entity, param5:Vector.<Entity_Base>, param6:Vector.<vec2>, param7:Number, param8:Number) : void
      {
         var _loc10_:Vector.<uint> = null;
         var _loc11_:uint = 0;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:uint = 0;
         var _loc15_:uint = 0;
         var _loc16_:Entity_BounceBlock = null;
         var _loc17_:Entity_Drone_Chaingun = null;
         var _loc18_:Entity_Drone_Chaser = null;
         var _loc19_:vec2 = null;
         var _loc20_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc22_:int = 0;
         var _loc23_:* = false;
         var _loc24_:Vector.<int> = null;
         var _loc25_:vec2 = null;
         var _loc26_:vec2 = null;
         var _loc27_:vec2 = null;
         var _loc28_:vec2 = null;
         var _loc29_:vec2 = null;
         var _loc30_:Segment_Linear_DoubleSided = null;
         var _loc31_:Entity_Door_Regular = null;
         var _loc32_:Vector.<uint> = null;
         var _loc33_:Number = NaN;
         var _loc34_:Number = NaN;
         var _loc35_:Entity_Door_Locked = null;
         var _loc36_:Entity_Door_Trap = null;
         var _loc37_:Entity_ExitDoor = null;
         var _loc38_:Vector.<uint> = null;
         var _loc39_:Number = NaN;
         var _loc40_:Number = NaN;
         var _loc41_:Entity_ExitSwitch = null;
         var _loc42_:Entity_FloorGuard = null;
         var _loc43_:Entity_Gold = null;
         var _loc44_:Entity_Drone_Laser = null;
         var _loc45_:vec2 = null;
         var _loc46_:Entity_Launchpad = null;
         var _loc47_:Entity_Mine = null;
         var _loc48_:vec2 = null;
         var _loc49_:Entity_OnewayPlatform = null;
         var _loc50_:Entity_Rocket = null;
         var _loc51_:vec2 = null;
         var _loc52_:Number = NaN;
         var _loc53_:Boolean = false;
         var _loc54_:Entity_Thwomp = null;
         var _loc55_:Entity_Turret = null;
         var _loc56_:Entity_Drone_Zap = null;
         param4.Clear();
         param5.length = 0;
         param6.length = 0;
         var _loc9_:int = 0;
         for(; _loc9_ < param1.length; _loc9_++)
         {
            _loc10_ = param1[_loc9_];
            _loc11_ = _loc10_[edat.EPROP_TYPE];
            _loc12_ = _loc10_[edat.EPROP_X] * edat.quantize_step_size;
            _loc13_ = _loc10_[edat.EPROP_Y] * edat.quantize_step_size;
            _loc14_ = 0;
            _loc15_ = 0;
            if(_loc10_.length > 3)
            {
               _loc14_ = _loc10_[edat.EPROP_DIR];
               if(_loc10_.length > 4)
               {
                  _loc15_ = _loc10_[edat.EPROP_MOVE];
               }
            }
            if(_loc11_ == edat.ETYPE_BOUNCEBLOCK)
            {
               _loc16_ = new Entity_BounceBlock(param4,_loc12_,_loc13_);
               Helper_RegisterEntity(param5,_loc16_);
            }
            else if(_loc11_ == edat.ETYPE_CHAINGUN)
            {
               _loc17_ = new Entity_Drone_Chaingun(param4,_loc12_,_loc13_,Helper_Editor_NewDirEnumToOldDirEnum(_loc14_),_loc15_);
               Helper_RegisterEntity(param5,_loc17_);
            }
            else if(_loc11_ == edat.ETYPE_CHASER)
            {
               _loc18_ = new Entity_Drone_Chaser(param4,_loc12_,_loc13_,Helper_Editor_NewDirEnumToOldDirEnum(_loc14_),_loc15_);
               Helper_RegisterEntity(param5,_loc18_);
            }
            else if(_loc11_ == edat.ETYPE_DOOR_LOCKED || _loc11_ == edat.ETYPE_DOOR_REGULAR || _loc11_ == edat.ETYPE_DOOR_TRAP)
            {
               _loc19_ = edat.MAP_DIR_TO_VEC(_loc14_);
               _loc20_ = Math.floor((_loc12_ - _loc19_.x * 12) / 24);
               _loc21_ = Math.floor((_loc13_ - _loc19_.y * 12) / 24);
               _loc22_ = param2.DOOR_GetCellIndexFromGridspacePosition(_loc20_,_loc21_);
               _loc23_ = _loc14_ == 0;
               _loc24_ = new Vector.<int>(2,true);
               if(!_loc23_)
               {
                  _loc24_[0] = param3.DOOR_GetCellIndexFromGridspacePosition(_loc20_ * 2,_loc21_ * 2 + 1);
                  _loc24_[1] = param3.DOOR_GetCellIndexFromGridspacePosition(_loc20_ * 2 + 1,_loc21_ * 2 + 1);
               }
               else
               {
                  _loc24_[0] = param3.DOOR_GetCellIndexFromGridspacePosition(_loc20_ * 2 + 1,_loc21_ * 2);
                  _loc24_[1] = param3.DOOR_GetCellIndexFromGridspacePosition(_loc20_ * 2 + 1,_loc21_ * 2 + 1);
               }
               _loc25_ = param2.DEBUG_GetWorldspaceCellCenterPositionFromIndex(_loc22_);
               _loc26_ = new vec2(_loc12_,_loc13_);
               _loc27_ = _loc19_.Perp();
               _loc27_.Scale(12);
               _loc28_ = _loc26_.Plus(_loc27_);
               _loc29_ = _loc26_.Minus(_loc27_);
               _loc30_ = new Segment_Linear_DoubleSided(_loc28_.x,_loc28_.y,_loc29_.x,_loc29_.y);
               if(_loc11_ == edat.ETYPE_DOOR_REGULAR)
               {
                  _loc31_ = new Entity_Door_Regular(param4,param2,_loc22_,_loc30_,param3,_loc24_,_loc23_,_loc12_,_loc13_);
                  Helper_RegisterEntity(param5,_loc31_);
               }
               else
               {
                  _loc32_ = param1[_loc9_ + 1];
                  _loc33_ = _loc32_[edat.EPROP_X] * edat.quantize_step_size;
                  _loc34_ = _loc32_[edat.EPROP_Y] * edat.quantize_step_size;
                  if(_loc11_ == edat.ETYPE_DOOR_LOCKED)
                  {
                     _loc35_ = new Entity_Door_Locked(param4,param2,_loc22_,_loc30_,param3,_loc24_,_loc23_,_loc33_,_loc34_);
                     Helper_RegisterEntity(param5,_loc35_);
                  }
                  else if(_loc11_ == edat.ETYPE_DOOR_TRAP)
                  {
                     _loc36_ = new Entity_Door_Trap(param4,param2,_loc22_,_loc30_,param3,_loc24_,_loc23_,_loc33_,_loc34_);
                     Helper_RegisterEntity(param5,_loc36_);
                  }
               }
            }
            else if(_loc11_ == edat.ETYPE_EXIT_DOOR)
            {
               _loc37_ = new Entity_ExitDoor(_loc12_,_loc13_);
               Helper_RegisterEntity(param5,_loc37_);
               _loc38_ = param1[_loc9_ + 1];
               _loc39_ = _loc38_[edat.EPROP_X] * edat.quantize_step_size;
               _loc40_ = _loc38_[edat.EPROP_Y] * edat.quantize_step_size;
               _loc41_ = new Entity_ExitSwitch(param4,_loc39_,_loc40_,_loc37_);
               Helper_RegisterEntity(param5,_loc41_);
            }
            else if(_loc11_ == edat.ETYPE_EXIT_SWITCH)
            {
               if(_loc9_ > 0)
               {
                  if(param1[_loc9_ - 1][edat.EPROP_TYPE] == edat.ETYPE_EXIT_DOOR)
                  {
                     continue;
                  }
               }
               trace("WARNING! LoadLevel_EditorState_Entities() found an exit switch without preceeding exit door!: " + _loc9_);
            }
            else if(_loc11_ == edat.ETYPE_FLOORGUARD)
            {
               _loc42_ = new Entity_FloorGuard(param4,_loc12_,_loc13_);
               Helper_RegisterEntity(param5,_loc42_);
            }
            else if(_loc11_ == edat.ETYPE_GOLD)
            {
               _loc43_ = new Entity_Gold(param4,_loc12_,_loc13_);
               Helper_RegisterEntity(param5,_loc43_);
            }
            else if(_loc11_ == edat.ETYPE_LASER)
            {
               _loc44_ = new Entity_Drone_Laser(param4,_loc12_,_loc13_,Helper_Editor_NewDirEnumToOldDirEnum(_loc14_),_loc15_);
               Helper_RegisterEntity(param5,_loc44_);
            }
            else if(_loc11_ == edat.ETYPE_LAUNCHPAD)
            {
               _loc45_ = edat.MAP_DIR_TO_VEC(_loc14_);
               _loc46_ = new Entity_Launchpad(param4,_loc12_,_loc13_,_loc45_.x,_loc45_.y);
               Helper_RegisterEntity(param5,_loc46_);
            }
            else if(_loc11_ == edat.ETYPE_MINE)
            {
               _loc47_ = new Entity_Mine(param4,_loc12_,_loc13_);
               Helper_RegisterEntity(param5,_loc47_);
            }
            else if(_loc11_ == edat.ETYPE_ONEWAY)
            {
               _loc48_ = edat.MAP_DIR_TO_VEC(_loc14_);
               _loc49_ = new Entity_OnewayPlatform(param4,_loc12_,_loc13_,_loc48_.x,_loc48_.y);
               Helper_RegisterEntity(param5,_loc49_);
            }
            else if(_loc11_ == edat.ETYPE_PLAYER)
            {
               param6.push(new vec2(_loc12_,_loc13_));
            }
            else if(_loc11_ == edat.ETYPE_ROCKET)
            {
               _loc50_ = new Entity_Rocket(param4,_loc12_,_loc13_);
               Helper_RegisterEntity(param5,_loc50_);
            }
            else if(_loc11_ == edat.ETYPE_SWITCH_LOCKED)
            {
               if(_loc9_ > 0)
               {
                  if(param1[_loc9_ - 1][edat.EPROP_TYPE] == edat.ETYPE_DOOR_LOCKED)
                  {
                     continue;
                  }
               }
               trace("WARNING! LoadLevel_EditorState_Entities() found a locked switch without preceeding locked door!: " + _loc9_);
            }
            else if(_loc11_ == edat.ETYPE_SWITCH_TRAP)
            {
               if(_loc9_ > 0)
               {
                  if(param1[_loc9_ - 1][edat.EPROP_TYPE] == edat.ETYPE_DOOR_TRAP)
                  {
                     continue;
                  }
               }
               trace("WARNING! LoadLevel_EditorState_Entities() found a locked switch without preceeding trap door!: " + _loc9_);
            }
            else if(_loc11_ == edat.ETYPE_THWOMP)
            {
               _loc51_ = edat.MAP_DIR_TO_VEC(_loc14_);
               _loc52_ = 0;
               _loc53_ = false;
               if(_loc51_.y == 0)
               {
                  _loc52_ = _loc51_.x;
                  _loc53_ = true;
               }
               else
               {
                  _loc52_ = _loc51_.y;
               }
               _loc54_ = new Entity_Thwomp(param4,_loc12_,_loc13_,_loc52_,_loc53_);
               Helper_RegisterEntity(param5,_loc54_);
            }
            else if(_loc11_ == edat.ETYPE_TURRET)
            {
               _loc55_ = new Entity_Turret(param4,_loc12_,_loc13_);
               Helper_RegisterEntity(param5,_loc55_);
            }
            else if(_loc11_ == edat.ETYPE_ZAP)
            {
               _loc56_ = new Entity_Drone_Zap(param4,_loc12_,_loc13_,Helper_Editor_NewDirEnumToOldDirEnum(_loc14_),_loc15_);
               Helper_RegisterEntity(param5,_loc56_);
            }
         }
      }
      
      public static function BuildEditorState_OldData(param1:String) : Editor_State
      {
         var _loc2_:Editor_State = new Editor_State();
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(edat.num_cols != 31)
         {
            _loc3_ = 5;
            _loc4_ = _loc3_ * edat.quantize_steps_per_cell;
         }
         var _loc5_:Array = param1.split(OLDDATA_SEPERATION_CHAR_LEVEL);
         if(_loc5_.length > 0)
         {
            BuildEditorState_OldData_Tiles(_loc5_[0],_loc2_.tileIDs,_loc3_);
         }
         if(_loc5_.length > 1)
         {
            BuildEditorState_OldData_Entities(_loc5_[1],_loc2_.entities,_loc4_);
         }
         return _loc2_;
      }
      
      private static function BuildEditorState_OldData_Tiles(param1:String, param2:Vector.<uint>, param3:int = 0) : void
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:String = null;
         var _loc9_:int = 0;
         if(param1.length != 31 * 23)
         {
            trace("WARNING! BuildEditorState_OldData_Tiles() was passed an invalid string: " + param1.length);
            return;
         }
         var _loc4_:int = 0;
         while(_loc4_ < param2.length)
         {
            param2[_loc4_] = tiletypes.FULL;
            _loc4_++;
         }
         var _loc5_:int = 0;
         while(_loc5_ < param1.length)
         {
            _loc6_ = _loc5_ % edat.num_rows;
            _loc7_ = Math.floor(_loc5_ / edat.num_rows);
            _loc8_ = param1.charAt(_loc5_);
            _loc9_ = _loc8_.charCodeAt(0) - OLDDATA_CHAR_PAD;
            param2[_loc7_ + _loc6_ * edat.num_cols + param3] = tiletypes.GetTypeFromChar(_loc9_);
            _loc5_++;
         }
      }
      
      private static function BuildEditorState_OldData_Entities(param1:String, param2:Vector.<Vector.<uint>>, param3:int = 0) : void
      {
         var _loc6_:Array = null;
         var _loc7_:int = 0;
         var _loc8_:Array = null;
         var _loc9_:Vector.<Number> = null;
         var _loc10_:int = 0;
         if(param1.length == 0)
         {
            return;
         }
         var _loc4_:Array = param1.split(OLDDATA_SEPERATION_CHAR_OBJECT);
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_.length)
         {
            _loc6_ = _loc4_[_loc5_].split(OLDDATA_SEPERATION_CHAR_OBJTYPE);
            _loc7_ = Number(_loc6_[0]);
            _loc8_ = _loc6_[1].split(OLDDATA_SEPERATION_CHAR_OBJPARAM);
            _loc9_ = new Vector.<Number>(_loc8_.length,true);
            _loc10_ = 0;
            while(_loc10_ < _loc8_.length)
            {
               _loc9_[_loc10_] = Number(_loc8_[_loc10_]);
               _loc10_++;
            }
            BuildEditorState_OldData_CreateEntity(_loc7_,_loc9_,param2,param3);
            _loc5_++;
         }
      }
      
      private static function BuildEditorState_OldData_CreateEntity(param1:int, param2:Vector.<Number>, param3:Vector.<Vector.<uint>>, param4:int = 0) : void
      {
         var _loc5_:Vector.<uint> = null;
         var _loc6_:Vector.<uint> = null;
         var _loc7_:Vector.<uint> = null;
         var _loc8_:Vector.<uint> = null;
         var _loc9_:vec2 = null;
         var _loc10_:Vector.<uint> = null;
         var _loc11_:Vector.<uint> = null;
         var _loc12_:Vector.<uint> = null;
         var _loc13_:Vector.<uint> = null;
         var _loc14_:Vector.<uint> = null;
         var _loc15_:Vector.<uint> = null;
         var _loc16_:Vector.<uint> = null;
         var _loc17_:Vector.<uint> = null;
         var _loc18_:Vector.<uint> = null;
         var _loc19_:int = 0;
         var _loc20_:int = 0;
         var _loc21_:* = false;
         var _loc22_:vec2 = null;
         var _loc23_:uint = 0;
         var _loc24_:Vector.<uint> = null;
         var _loc25_:Vector.<uint> = null;
         var _loc26_:Vector.<uint> = null;
         var _loc27_:Vector.<uint> = null;
         var _loc28_:Vector.<uint> = null;
         var _loc29_:Vector.<uint> = null;
         var _loc30_:Vector.<uint> = null;
         var _loc31_:Vector.<uint> = null;
         if(param1 == OLDDATA_OBJTYPE_BOUNCEBLOCK)
         {
            if(param2.length == 2)
            {
               _loc5_ = new Vector.<uint>(3,true);
               _loc5_[edat.EPROP_TYPE] = edat.ETYPE_BOUNCEBLOCK;
               _loc5_[edat.EPROP_X] = Helper_Editor_GetQuantizedPosition(param2[0]) + param4;
               _loc5_[edat.EPROP_Y] = Helper_Editor_GetQuantizedPosition(param2[1]);
               param3.push(_loc5_);
            }
         }
         else if(param1 == OLDDATA_OBJTYPE_GOLD)
         {
            if(param2.length == 2)
            {
               _loc6_ = new Vector.<uint>(3,true);
               _loc6_[edat.EPROP_TYPE] = edat.ETYPE_GOLD;
               _loc6_[edat.EPROP_X] = Helper_Editor_GetQuantizedPosition(param2[0]) + param4;
               _loc6_[edat.EPROP_Y] = Helper_Editor_GetQuantizedPosition(param2[1]);
               param3.push(_loc6_);
            }
         }
         else if(param1 == OLDDATA_OBJTYPE_LAUNCHPAD)
         {
            if(param2.length == 4)
            {
               _loc7_ = new Vector.<uint>(4,true);
               _loc7_[edat.EPROP_TYPE] = edat.ETYPE_LAUNCHPAD;
               _loc7_[edat.EPROP_X] = Helper_Editor_GetQuantizedPosition(param2[0]) + param4;
               _loc7_[edat.EPROP_Y] = Helper_Editor_GetQuantizedPosition(param2[1]);
               _loc7_[edat.EPROP_DIR] = Helper_Editor_VecToDirEnum(param2[2],param2[3]);
               param3.push(_loc7_);
            }
         }
         else if(param1 == OLDDATA_OBJTYPE_MINE)
         {
            if(param2.length == 2)
            {
               _loc8_ = new Vector.<uint>(3,true);
               _loc8_[edat.EPROP_TYPE] = edat.ETYPE_MINE;
               _loc8_[edat.EPROP_X] = Helper_Editor_GetQuantizedPosition(param2[0]) + param4;
               _loc8_[edat.EPROP_Y] = Helper_Editor_GetQuantizedPosition(param2[1]);
               param3.push(_loc8_);
            }
         }
         else if(param1 == OLDDATA_OBJTYPE_ONEWAYPLATFORM)
         {
            if(param2.length == 3)
            {
               _loc9_ = HELPER_OldData_UnpackDirEnum(param2[2]);
               _loc10_ = new Vector.<uint>(4,true);
               _loc10_[edat.EPROP_TYPE] = edat.ETYPE_ONEWAY;
               _loc10_[edat.EPROP_X] = Helper_Editor_GetQuantizedPosition(param2[0] + 12 * _loc9_.x) + param4;
               _loc10_[edat.EPROP_Y] = Helper_Editor_GetQuantizedPosition(param2[1] + 12 * _loc9_.y);
               _loc10_[edat.EPROP_DIR] = Helper_Editor_OldDirEnumToNewDirEnum(param2[2]);
               param3.push(_loc10_);
               if(Helper_Editor_VecToDirEnum(_loc9_.x,_loc9_.y) != Helper_Editor_OldDirEnumToNewDirEnum(param2[2]))
               {
                  trace("WARNING! BuildEditorState_OldData_Entities() found a problem with its dir-enum helpers: " + Helper_Editor_VecToDirEnum(_loc9_.x,_loc9_.y) + "," + Helper_Editor_OldDirEnumToNewDirEnum(param2[2]));
               }
            }
         }
         else if(param1 == OLDDATA_OBJTYPE_DRONE)
         {
            if(param2.length == 6)
            {
               if(Boolean(param2[3]))
               {
                  _loc11_ = new Vector.<uint>(5,true);
                  _loc11_[edat.EPROP_TYPE] = edat.ETYPE_CHASER;
                  _loc11_[edat.EPROP_X] = Helper_Editor_GetQuantizedPosition(param2[0]) + param4;
                  _loc11_[edat.EPROP_Y] = Helper_Editor_GetQuantizedPosition(param2[1]);
                  _loc11_[edat.EPROP_DIR] = Helper_Editor_OldDirEnumToNewDirEnum(param2[5]);
                  _loc11_[edat.EPROP_MOVE] = uint(Math.min(3,param2[2]));
                  param3.push(_loc11_);
               }
               else if(param2[4] == 0)
               {
                  _loc12_ = new Vector.<uint>(5,true);
                  _loc12_[edat.EPROP_TYPE] = edat.ETYPE_ZAP;
                  _loc12_[edat.EPROP_X] = Helper_Editor_GetQuantizedPosition(param2[0]) + param4;
                  _loc12_[edat.EPROP_Y] = Helper_Editor_GetQuantizedPosition(param2[1]);
                  _loc12_[edat.EPROP_DIR] = Helper_Editor_OldDirEnumToNewDirEnum(param2[5]);
                  _loc12_[edat.EPROP_MOVE] = uint(Math.min(3,param2[2]));
                  param3.push(_loc12_);
               }
               else if(param2[4] == 1)
               {
                  _loc13_ = new Vector.<uint>(5,true);
                  _loc13_[edat.EPROP_TYPE] = edat.ETYPE_LASER;
                  _loc13_[edat.EPROP_X] = Helper_Editor_GetQuantizedPosition(param2[0]) + param4;
                  _loc13_[edat.EPROP_Y] = Helper_Editor_GetQuantizedPosition(param2[1]);
                  _loc13_[edat.EPROP_DIR] = Helper_Editor_OldDirEnumToNewDirEnum(param2[5]);
                  _loc13_[edat.EPROP_MOVE] = uint(Math.min(3,param2[2]));
                  param3.push(_loc13_);
               }
               else if(param2[4] == 2)
               {
                  _loc14_ = new Vector.<uint>(5,true);
                  _loc14_[edat.EPROP_TYPE] = edat.ETYPE_CHAINGUN;
                  _loc14_[edat.EPROP_X] = Helper_Editor_GetQuantizedPosition(param2[0]) + param4;
                  _loc14_[edat.EPROP_Y] = Helper_Editor_GetQuantizedPosition(param2[1]);
                  _loc14_[edat.EPROP_DIR] = Helper_Editor_OldDirEnumToNewDirEnum(param2[5]);
                  _loc14_[edat.EPROP_MOVE] = uint(Math.min(3,param2[2]));
                  param3.push(_loc14_);
               }
            }
            else
            {
               trace("WARNING! BuildEditorState_OldData_CreateEntity() was passed an invalid set of params: " + param2.length);
            }
         }
         else if(param1 == OLDDATA_OBJTYPE_EXIT)
         {
            if(param2.length == 4)
            {
               _loc15_ = new Vector.<uint>(3,true);
               _loc15_[edat.EPROP_TYPE] = edat.ETYPE_EXIT_DOOR;
               _loc15_[edat.EPROP_X] = Helper_Editor_GetQuantizedPosition(param2[0]) + param4;
               _loc15_[edat.EPROP_Y] = Helper_Editor_GetQuantizedPosition(param2[1]);
               param3.push(_loc15_);
               _loc16_ = new Vector.<uint>(3,true);
               _loc16_[edat.EPROP_TYPE] = edat.ETYPE_EXIT_SWITCH;
               _loc16_[edat.EPROP_X] = Helper_Editor_GetQuantizedPosition(param2[2]) + param4;
               _loc16_[edat.EPROP_Y] = Helper_Editor_GetQuantizedPosition(param2[3]);
               param3.push(_loc16_);
            }
         }
         else if(param1 == OLDDATA_OBJTYPE_FLOORGUARD)
         {
            if(param2.length == 3)
            {
               _loc17_ = new Vector.<uint>(3,true);
               _loc17_[edat.EPROP_TYPE] = edat.ETYPE_FLOORGUARD;
               _loc17_[edat.EPROP_X] = Helper_Editor_GetQuantizedPosition(param2[0]) + param4;
               _loc17_[edat.EPROP_Y] = Helper_Editor_GetQuantizedPosition(param2[1]);
               param3.push(_loc17_);
            }
         }
         else if(param1 == OLDDATA_OBJTYPE_HOMINGLAUNCHER)
         {
            if(param2.length == 2)
            {
               _loc18_ = new Vector.<uint>(3,true);
               _loc18_[edat.EPROP_TYPE] = edat.ETYPE_ROCKET;
               _loc18_[edat.EPROP_X] = Helper_Editor_GetQuantizedPosition(param2[0]) + param4;
               _loc18_[edat.EPROP_Y] = Helper_Editor_GetQuantizedPosition(param2[1]);
               param3.push(_loc18_);
            }
         }
         else if(param1 == OLDDATA_OBJTYPE_TESTDOOR)
         {
            if(param2.length == 9)
            {
               _loc19_ = param2[4] + param2[7];
               _loc20_ = param2[5] + param2[8];
               _loc21_ = param2[2] != 1;
               _loc22_ = new vec2((0.5 + _loc19_) * 24,(0.5 + _loc20_) * 24);
               _loc23_ = 0;
               if(_loc21_)
               {
                  _loc22_.x += 12;
               }
               else
               {
                  _loc22_.y += 12;
                  _loc23_ = 2;
               }
               if(Boolean(param2[3]))
               {
                  _loc24_ = new Vector.<uint>(4,true);
                  _loc24_[edat.EPROP_TYPE] = edat.ETYPE_DOOR_TRAP;
                  _loc24_[edat.EPROP_X] = Helper_Editor_GetQuantizedPosition(_loc22_.x) + param4;
                  _loc24_[edat.EPROP_Y] = Helper_Editor_GetQuantizedPosition(_loc22_.y);
                  _loc24_[edat.EPROP_DIR] = _loc23_;
                  param3.push(_loc24_);
                  _loc25_ = new Vector.<uint>(3,true);
                  _loc25_[edat.EPROP_TYPE] = edat.ETYPE_SWITCH_TRAP;
                  _loc25_[edat.EPROP_X] = Helper_Editor_GetQuantizedPosition(param2[0]) + param4;
                  _loc25_[edat.EPROP_Y] = Helper_Editor_GetQuantizedPosition(param2[1]);
                  param3.push(_loc25_);
               }
               else if(Boolean(param2[6]))
               {
                  _loc26_ = new Vector.<uint>(4,true);
                  _loc26_[edat.EPROP_TYPE] = edat.ETYPE_DOOR_LOCKED;
                  _loc26_[edat.EPROP_X] = Helper_Editor_GetQuantizedPosition(_loc22_.x) + param4;
                  _loc26_[edat.EPROP_Y] = Helper_Editor_GetQuantizedPosition(_loc22_.y);
                  _loc26_[edat.EPROP_DIR] = _loc23_;
                  param3.push(_loc26_);
                  _loc27_ = new Vector.<uint>(3,true);
                  _loc27_[edat.EPROP_TYPE] = edat.ETYPE_SWITCH_LOCKED;
                  _loc27_[edat.EPROP_X] = Helper_Editor_GetQuantizedPosition(param2[0]) + param4;
                  _loc27_[edat.EPROP_Y] = Helper_Editor_GetQuantizedPosition(param2[1]);
                  param3.push(_loc27_);
               }
               else
               {
                  _loc28_ = new Vector.<uint>(4,true);
                  _loc28_[edat.EPROP_TYPE] = edat.ETYPE_DOOR_REGULAR;
                  _loc28_[edat.EPROP_X] = Helper_Editor_GetQuantizedPosition(_loc22_.x) + param4;
                  _loc28_[edat.EPROP_Y] = Helper_Editor_GetQuantizedPosition(_loc22_.y);
                  _loc28_[edat.EPROP_DIR] = _loc23_;
                  param3.push(_loc28_);
               }
            }
         }
         else if(param1 == OLDDATA_OBJTYPE_THWOMP)
         {
            if(param2.length == 3)
            {
               _loc29_ = new Vector.<uint>(4,true);
               _loc29_[edat.EPROP_TYPE] = edat.ETYPE_THWOMP;
               _loc29_[edat.EPROP_X] = Helper_Editor_GetQuantizedPosition(param2[0]) + param4;
               _loc29_[edat.EPROP_Y] = Helper_Editor_GetQuantizedPosition(param2[1]);
               _loc29_[edat.EPROP_DIR] = Helper_Editor_OldDirEnumToNewDirEnum(param2[2]);
               param3.push(_loc29_);
            }
         }
         else if(param1 == OLDDATA_OBJTYPE_TURRET)
         {
            if(param2.length == 2)
            {
               _loc30_ = new Vector.<uint>(3,true);
               _loc30_[edat.EPROP_TYPE] = edat.ETYPE_TURRET;
               _loc30_[edat.EPROP_X] = Helper_Editor_GetQuantizedPosition(param2[0]) + param4;
               _loc30_[edat.EPROP_Y] = Helper_Editor_GetQuantizedPosition(param2[1]);
               param3.push(_loc30_);
            }
         }
         else if(param1 == OLDDATA_OBJTYPE_PLAYER)
         {
            if(param2.length == 2)
            {
               _loc31_ = new Vector.<uint>(3,true);
               _loc31_[edat.EPROP_TYPE] = edat.ETYPE_PLAYER;
               _loc31_[edat.EPROP_X] = Helper_Editor_GetQuantizedPosition(param2[0]) + param4;
               _loc31_[edat.EPROP_Y] = Helper_Editor_GetQuantizedPosition(param2[1]);
               param3.push(_loc31_);
            }
         }
      }
      
      private static function Helper_Editor_GetQuantizedPosition(param1:Number) : uint
      {
         return Math.round(param1 / Number(edat.quantize_step_size));
      }
      
      private static function Helper_Editor_OldDirEnumToNewDirEnum(param1:Number) : uint
      {
         return uint(param1 * 2);
      }
      
      private static function Helper_Editor_NewDirEnumToOldDirEnum(param1:uint) : int
      {
         return Math.floor(param1 / 2);
      }
      
      private static function Helper_Editor_VecToDirEnum(param1:Number, param2:Number) : uint
      {
         if(param1 == 0)
         {
            if(param2 == 0)
            {
               trace("WARNING! Helper_Editor_VecToDirEnum() was passed an invalid dir!:" + param1 + "," + param2);
               return 0;
            }
            if(param2 < 1)
            {
               return edat.DIR_U;
            }
            return edat.DIR_D;
         }
         if(param2 == 0)
         {
            if(param1 == 0)
            {
               trace("WARNING! Helper_Editor_VecToDirEnum() was passed an invalid dir!:" + param1 + "," + param2);
               return 0;
            }
            if(param1 < 1)
            {
               return edat.DIR_L;
            }
            return edat.DIR_R;
         }
         if(param1 < 0)
         {
            if(param2 < 0)
            {
               return edat.DIR_LU;
            }
            return edat.DIR_LD;
         }
         if(param2 < 0)
         {
            return edat.DIR_RU;
         }
         return edat.DIR_RD;
      }
   }
}

