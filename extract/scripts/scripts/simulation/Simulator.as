package simulation
{
   import audiovisual.GraphicsManager;
   import audiovisual.ParticleManager;
   import audiovisual.SoundManager;
   import editor.edat;
   import flash.utils.ByteArray;
   import math.mathutils;
   import math.vec2;
   import simpleFramework.SimpleRenderer;
   import simulation.collision.Grid_Edges;
   import simulation.collision.Grid_Entity;
   import simulation.collision.Grid_Segment;
   import simulation.collision.Segment;
   import simulation.entities.Entity_Base;
   import simulation.ninja.Ninja;
   
   public class Simulator
   {
      
      public static const GRID_NUM_COLS:int = edat.num_cols + 2;
      
      public static const GRID_NUM_ROWS:int = edat.num_rows + 2;
      
      public static const GRID_CELL_SIZE:Number = 24;
      
      public static const GRID_CELL_HALFWIDTH:Number = GRID_CELL_SIZE / 2;
      
      private var objList:Vector.<Entity_Base>;
      
      private var tileIDs:Vector.<int>;
      
      public var segGrid:Grid_Segment;
      
      public var edgeGrid:Grid_Edges;
      
      public var objGrid:Grid_Entity;
      
      public var playerList:Vector.<Ninja>;
      
      private var frame_num:uint;
      
      private var num_gold_collected_during_tick:Vector.<int>;
      
      private var STATEFLAG_won:Boolean;
      
      private var HACKY_gfx:GraphicsManager;
      
      private var HACKY_sfx:SoundManager;
      
      public function Simulator(param1:Vector.<int>, param2:Grid_Segment, param3:Grid_Edges, param4:Grid_Entity, param5:Vector.<Entity_Base>, param6:Vector.<Ninja>)
      {
         super();
         this.tileIDs = param1;
         this.segGrid = param2;
         this.edgeGrid = param3;
         this.objGrid = param4;
         this.objList = param5;
         this.playerList = param6;
         this.frame_num = 0;
         this.num_gold_collected_during_tick = new Vector.<int>(param6.length,true);
         this.STATEFLAG_won = false;
         this.HACKY_gfx = null;
         this.HACKY_sfx = null;
         mathutils.SetRandomSeed(1);
      }
      
      public function HACKY_SetAV(param1:GraphicsManager, param2:SoundManager) : void
      {
         this.HACKY_gfx = param1;
         this.HACKY_sfx = param2;
      }
      
      public function HACKY_GetParticleManager() : ParticleManager
      {
         return this.HACKY_gfx.GetParticleManager();
      }
      
      public function HACKY_GetSoundManager() : SoundManager
      {
         return this.HACKY_sfx;
      }
      
      public function GFX_GetEntityList() : Vector.<Entity_Base>
      {
         return this.objList;
      }
      
      public function GFX_GetPlayerList() : Vector.<Ninja>
      {
         return this.playerList;
      }
      
      public function GFX_GetTileIDs() : Vector.<int>
      {
         return this.tileIDs;
      }
      
      public function Tick(param1:SimpleRenderer) : void
      {
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc2_:int = 0;
         while(_loc2_ < this.num_gold_collected_during_tick.length)
         {
            this.num_gold_collected_during_tick[_loc2_] = 0;
            _loc2_++;
         }
         var _loc3_:int = 0;
         while(_loc3_ < this.objList.length)
         {
            this.objList[_loc3_].Move(this);
            _loc3_++;
         }
         var _loc4_:int = 0;
         while(_loc4_ < this.objList.length)
         {
            this.objList[_loc4_].Think(this);
            _loc4_++;
         }
         var _loc5_:int = 0;
         while(_loc5_ < this.playerList.length)
         {
            this.playerList[_loc5_].Integrate();
            this.playerList[_loc5_].PreCollision();
            _loc5_++;
         }
         var _loc6_:int = 4;
         var _loc7_:int = 0;
         while(_loc7_ < _loc6_)
         {
            _loc10_ = 0;
            while(_loc10_ < this.playerList.length)
            {
               this.playerList[_loc10_].SolveInternalConstraints();
               _loc10_++;
            }
            _loc11_ = 0;
            while(_loc11_ < this.playerList.length)
            {
               this.playerList[_loc11_].CollideVsObjects(this);
               _loc11_++;
            }
            _loc12_ = 0;
            while(_loc12_ < this.playerList.length)
            {
               this.playerList[_loc12_].CollideVsTiles(this);
               _loc12_++;
            }
            _loc7_++;
         }
         var _loc8_:int = 0;
         while(_loc8_ < this.playerList.length)
         {
            this.playerList[_loc8_].PostCollision(this);
            _loc8_++;
         }
         var _loc9_:int = 0;
         while(_loc9_ < this.playerList.length)
         {
            this.playerList[_loc9_].Think(this,this.frame_num);
            _loc9_++;
         }
         ++this.frame_num;
      }
      
      private function InternalEvent_KillPlayer(param1:Ninja, param2:int, param3:Number, param4:Number, param5:Number, param6:Number) : void
      {
         if(param1.SIM_Kill(param2,param3,param4,param5,param6))
         {
         }
      }
      
      public function Event_Launchpad_HitPlayer(param1:Ninja, param2:Number, param3:Number) : void
      {
         param1.SIM_Launch(param2,param3);
      }
      
      public function Event_Exit_HitPlayer(param1:Ninja) : void
      {
         this.STATEFLAG_won = true;
         var _loc2_:int = 0;
         while(_loc2_ < this.playerList.length)
         {
            this.playerList[_loc2_].SIM_Win();
            _loc2_++;
         }
      }
      
      public function Event_Gold_HitPlayer(param1:Ninja) : Boolean
      {
         if(!this.STATEFLAG_won)
         {
            ++this.num_gold_collected_during_tick[param1.GetIndex()];
            return true;
         }
         return false;
      }
      
      public function Event_PlayerWasKilled(param1:Ninja, param2:int, param3:Number, param4:Number, param5:Number, param6:Number) : void
      {
         this.InternalEvent_KillPlayer(param1,param2,param3,param4,param5,param6);
      }
      
      private function AreAllPlayersDead() : Boolean
      {
         var _loc1_:int = 0;
         while(_loc1_ < this.playerList.length)
         {
            if(!this.playerList[_loc1_].IsDead())
            {
               return false;
            }
            _loc1_++;
         }
         return true;
      }
      
      public function APP_Event_TimeUp() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this.playerList.length)
         {
            this.InternalEvent_KillPlayer(this.playerList[_loc1_],sim_globals.ENEMYTYPE_TIME,0,0,0,0);
            _loc1_++;
         }
      }
      
      public function APP_Event_Suicide(param1:int) : void
      {
         this.InternalEvent_KillPlayer(this.playerList[param1],sim_globals.ENEMYTYPE_SUICIDE,0,0,0,0);
      }
      
      public function APP_IsPlayerDead(param1:int) : Boolean
      {
         return this.playerList[param1].IsDead();
      }
      
      public function APP_IsGameDone() : Boolean
      {
         return this.STATEFLAG_won || this.AreAllPlayersDead();
      }
      
      public function APP_DidPlayerWin() : Boolean
      {
         if(!this.APP_IsGameDone())
         {
            trace("WARNING! sim.APP_DidPlayerWin() was called, but APP_IsGameDone() wasn\'t consulted -- check it FIRST!");
            return false;
         }
         if(this.STATEFLAG_won)
         {
            return true;
         }
         return false;
      }
      
      public function APP_EnablePlayer(param1:int) : void
      {
         this.playerList[param1].APP_Enable();
      }
      
      public function APP_DisablePlayer(param1:int) : void
      {
         this.playerList[param1].APP_Disable();
      }
      
      public function App_EnableAllPlayers() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this.playerList.length)
         {
            this.playerList[_loc1_].APP_Enable();
            _loc1_++;
         }
      }
      
      public function App_DisableAllPlayers() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this.playerList.length)
         {
            this.playerList[_loc1_].APP_Disable();
            _loc1_++;
         }
      }
      
      public function APP_GetNumGoldCollectedDuringTick(param1:int) : int
      {
         return this.num_gold_collected_during_tick[param1];
      }
      
      public function APP_IsPlaybackFinished() : Boolean
      {
         var _loc1_:int = 0;
         while(_loc1_ < this.playerList.length)
         {
            if(!this.playerList[_loc1_].inputsource.IsReplayFinished())
            {
               return false;
            }
            _loc1_++;
         }
         return true;
      }
      
      public function APP_GetReplayData(param1:Vector.<String>) : void
      {
         var _loc3_:String = null;
         var _loc2_:int = 0;
         while(_loc2_ < this.playerList.length)
         {
            _loc3_ = this.playerList[_loc2_].inputsource.DumpString();
            param1.push(_loc3_);
            _loc2_++;
         }
      }
      
      public function APP_GetReplayBytes() : Vector.<ByteArray>
      {
         var _loc3_:ByteArray = null;
         var _loc1_:Vector.<ByteArray> = new Vector.<ByteArray>();
         var _loc2_:int = 0;
         while(_loc2_ < this.playerList.length)
         {
            _loc3_ = this.playerList[_loc2_].inputsource.DumpFrames();
            _loc1_.push(_loc3_);
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function DEBUG_SetPlayerPosVel(param1:vec2, param2:vec2) : void
      {
         var _loc3_:int = 0;
         while(_loc3_ < this.playerList.length)
         {
            this.playerList[_loc3_].DEBUG_SetPosVel(param1,param2);
            _loc3_++;
         }
      }
      
      public function DEATHMATCH_RespawnPlayer(param1:int) : void
      {
         if(this.playerList[param1].IsDead())
         {
            this.playerList[param1].DEBUG_Respawn(this.playerList[param1].GetPos());
         }
      }
      
      public function DEATHMATCH_GibPlayer(param1:int, param2:Number, param3:Number, param4:Number, param5:Number) : void
      {
         var _loc6_:Number = 0.8;
         if(!this.playerList[param1].IsDead())
         {
            this.playerList[param1].SIM_Kill(sim_globals.ENEMYTYPE_MINE,0,0,0,0);
         }
      }
      
      public function DEBUG_ToggleRagdoll(param1:vec2) : void
      {
         var _loc3_:vec2 = null;
         var _loc4_:Number = NaN;
         var _loc5_:vec2 = null;
         var _loc6_:Number = NaN;
         var _loc7_:vec2 = null;
         var _loc2_:int = 0;
         while(_loc2_ < this.playerList.length)
         {
            if(this.playerList[_loc2_].IsDead())
            {
               this.playerList[_loc2_].DEBUG_Respawn(param1);
            }
            else
            {
               _loc3_ = this.playerList[_loc2_].GetPos();
               _loc4_ = this.playerList[_loc2_].GetRadius();
               _loc5_ = param1.To(_loc3_);
               _loc6_ = Math.min(10,_loc5_.Len());
               _loc5_.Normalize();
               _loc7_ = _loc5_.Clone();
               _loc7_.Scale(_loc6_);
               this.playerList[_loc2_].SIM_Kill(sim_globals.ENEMYTYPE_DEBUG,_loc3_.x - _loc5_.x * _loc4_,_loc3_.y - _loc5_.y * _loc4_,_loc7_.x,_loc7_.y);
            }
            _loc2_++;
         }
      }
      
      public function DEBUG_ToggleExploded() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this.playerList.length)
         {
            if(this.playerList[_loc1_].IsDead())
            {
               if(this.playerList[_loc1_].DEBUG_GetRagdoll().DEBUG_IsExploded())
               {
                  this.playerList[_loc1_].DEBUG_GetRagdoll().UnexplodeRagdoll();
               }
               else
               {
                  this.playerList[_loc1_].DEBUG_GetRagdoll().ExplodeRagdoll(this);
               }
            }
            _loc1_++;
         }
      }
      
      public function DEBUG_GrabRagdoll(param1:vec2, param2:vec2) : void
      {
         var _loc3_:int = 0;
         while(_loc3_ < this.playerList.length)
         {
            if(this.playerList[_loc3_].IsDead())
            {
               this.playerList[_loc3_].DEBUG_GetRagdoll().TESTING_SetPosVel(param1,param2);
            }
            _loc3_++;
         }
      }
      
      public function DEBUG_Draw_Tiles(param1:SimpleRenderer) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Vector.<Segment> = null;
         var _loc5_:int = 0;
         param1.SetStyle(0,0,100);
         param1.DrawAABB(0,GRID_NUM_COLS * GRID_CELL_SIZE,0,GRID_NUM_ROWS * GRID_CELL_SIZE);
         param1.SetStyle(0,11184810,100);
         var _loc2_:int = 0;
         while(_loc2_ < GRID_NUM_COLS)
         {
            _loc3_ = 0;
            while(_loc3_ < GRID_NUM_ROWS)
            {
               _loc4_ = this.segGrid.DEBUG_GetCellContentsFromGridspacePosition(_loc2_,_loc3_);
               _loc5_ = 0;
               while(_loc5_ < _loc4_.length)
               {
                  _loc4_[_loc5_].DebugDraw_Simple(param1);
                  _loc5_++;
               }
               _loc3_++;
            }
            _loc2_++;
         }
      }
      
      public function DEBUG_Draw_Edges(param1:SimpleRenderer) : void
      {
         this.edgeGrid.Debug_Draw(param1);
      }
      
      public function DEBUG_Draw_objGrid(param1:SimpleRenderer) : void
      {
         this.objGrid.Debug_Draw(param1);
      }
      
      public function DEBUG_Draw_Grid(param1:SimpleRenderer) : void
      {
         var _loc3_:int = 0;
         param1.SetStyle(0,11184810,10);
         var _loc2_:int = 0;
         while(_loc2_ < GRID_NUM_COLS)
         {
            _loc3_ = 0;
            while(_loc3_ < GRID_NUM_ROWS)
            {
               param1.DrawAABB(_loc2_ * GRID_CELL_SIZE,(_loc2_ + 1) * GRID_CELL_SIZE,_loc3_ * GRID_CELL_SIZE,(_loc3_ + 1) * GRID_CELL_SIZE);
               _loc3_++;
            }
            _loc2_++;
         }
      }
      
      public function DEBUG_Draw_Entities(param1:SimpleRenderer) : void
      {
         var _loc4_:Entity_Base = null;
         var _loc2_:int = 0;
         while(_loc2_ < this.objList.length)
         {
            _loc4_ = this.objList[_loc2_];
            param1.SetStyle(0,0,100);
            _loc4_.Debug_Draw(param1);
            _loc2_++;
         }
         var _loc3_:int = 0;
         while(_loc3_ < this.playerList.length)
         {
            this.playerList[_loc3_].Draw(param1);
            _loc3_++;
         }
      }
   }
}

