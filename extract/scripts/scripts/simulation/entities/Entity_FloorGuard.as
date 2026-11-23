package simulation.entities
{
   import audiovisual.entitygraphics.EntityGraphics;
   import audiovisual.entitygraphics.EntityGraphics_FloorGuard;
   import math.vec2;
   import simpleFramework.SimpleRenderer;
   import simulation.Simulator;
   import simulation.collision.Grid_Edges;
   import simulation.collision.Grid_Entity;
   import simulation.collision.colutils;
   import simulation.ninja.Ninja;
   import simulation.sim_globals;
   
   public class Entity_FloorGuard extends Entity_Base
   {
      
      private var pos:vec2;
      
      private var speed:Number;
      
      private var r:Number;
      
      private var CUR_STATE:int;
      
      private var margin:Number;
      
      public function Entity_FloorGuard(param1:Grid_Entity, param2:Number, param3:Number)
      {
         super();
         this.pos = new vec2(param2,param3);
         this.r = 12 * 0.5;
         this.speed = 12 * (3 / 7) * (40 / sim_globals.sim_rate);
         this.CUR_STATE = 0;
         this.margin = 0;
         param1.ENTITY_Add(this.pos,this);
      }
      
      override public function CollideVsCircle_Logical(param1:Simulator, param2:Ninja, param3:collision_result_logical, param4:vec2, param5:vec2, param6:vec2, param7:Number, param8:Number) : Boolean
      {
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         if(colutils.Overlap_Circle_Vs_Circle(this.pos,this.r,param4,param7))
         {
            _loc9_ = param4.x - this.pos.x;
            _loc10_ = param4.y - this.pos.y;
            _loc11_ = Math.sqrt(_loc9_ * _loc9_ + _loc10_ * _loc10_);
            _loc9_ /= _loc11_;
            _loc10_ /= _loc11_;
            param1.HACKY_GetParticleManager().Spawn_Zap(this.pos.x + _loc9_ * this.r,this.pos.y + _loc10_ * this.r,Math.atan2(_loc10_,_loc9_) / Math.PI * 180);
            if(param2 == null)
            {
               param3.vec_x = _loc9_ * 10;
               param3.vec_y = _loc10_ * 10;
               return true;
            }
            param1.Event_PlayerWasKilled(param2,sim_globals.ENEMYTYPE_FLOORGUARD,param4.x - _loc9_ * param7,param4.y - _loc10_ * param7,_loc9_ * 10,_loc10_ * 10);
         }
         return false;
      }
      
      override public function Think(param1:Simulator) : void
      {
         var _loc2_:Grid_Edges = null;
         var _loc3_:int = 0;
         var _loc4_:Ninja = null;
         var _loc5_:vec2 = null;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         if(this.CUR_STATE == 0)
         {
            _loc2_ = param1.edgeGrid;
            _loc3_ = 0;
            while(_loc3_ < param1.playerList.length)
            {
               _loc4_ = param1.playerList[_loc3_];
               if(!_loc4_.IsDead())
               {
                  _loc5_ = _loc4_.GetPos();
                  _loc6_ = this.pos.y + this.r;
                  _loc7_ = _loc6_ - 24;
                  if(_loc5_.y >= _loc7_ && _loc5_.y <= _loc6_)
                  {
                     _loc8_ = _loc2_.GetGridCoordinateFromWorldspace_1D(_loc5_.x);
                     _loc9_ = _loc2_.GetGridCoordinateFromWorldspace_1D(this.pos.x);
                     _loc10_ = _loc2_.GetGridCoordinateFromWorldspace_1D(this.pos.y);
                     _loc11_ = 0;
                     if(_loc2_.ScanHorizontal(_loc10_,_loc10_,_loc9_,_loc8_))
                     {
                        _loc11_ = 1;
                        if(_loc5_.x < this.pos.x)
                        {
                           _loc11_ = -1;
                        }
                     }
                     if(_loc11_ != 0)
                     {
                        this.CUR_STATE = _loc11_;
                        break;
                     }
                  }
               }
               _loc3_++;
            }
         }
      }
      
      override public function Move(param1:Simulator) : void
      {
         var _loc8_:int = 0;
         if(this.CUR_STATE == 0)
         {
            return;
         }
         var _loc2_:Grid_Edges = param1.edgeGrid;
         var _loc3_:Number = this.r + this.margin;
         var _loc4_:Number = this.pos.x + this.CUR_STATE * this.speed;
         var _loc5_:Number = this.CUR_STATE * _loc3_;
         var _loc6_:int = _loc2_.GetGridCoordinateFromWorldspace_1D(this.pos.x + _loc5_);
         var _loc7_:int = _loc2_.GetGridCoordinateFromWorldspace_1D(_loc4_ + _loc5_);
         if(_loc6_ != _loc7_)
         {
            _loc8_ = _loc2_.GetGridCoordinateFromWorldspace_1D(this.pos.y);
            if(!_loc2_.IsEmpty(_loc6_,_loc8_,this.CUR_STATE,0) || !_loc2_.IsSolid_IgnoreDoors(_loc7_,_loc8_,0,1))
            {
               _loc4_ = _loc2_.GetWorldspaceCoordinateFromGridEdge_1D(_loc6_,this.CUR_STATE) - this.CUR_STATE * (_loc3_ + 0.01);
               this.CUR_STATE = 0;
            }
         }
         this.pos.x = _loc4_;
         param1.objGrid.ENTITY_Move(this.pos,this);
      }
      
      override public function GenerateGraphicComponent() : EntityGraphics
      {
         return new EntityGraphics_FloorGuard(this);
      }
      
      public function GFX_UpdateState(param1:EntityGraphics_FloorGuard) : void
      {
         param1.pos.x = this.pos.x;
         param1.pos.y = this.pos.y;
         if(this.CUR_STATE == 0)
         {
            param1.anim = EntityGraphics_FloorGuard.ANIM_IDLE;
         }
         else if(this.CUR_STATE == -1)
         {
            param1.anim = EntityGraphics_FloorGuard.ANIM_CHASE_L;
         }
         else
         {
            param1.anim = EntityGraphics_FloorGuard.ANIM_CHASE_R;
         }
      }
      
      override public function Debug_Draw(param1:SimpleRenderer) : void
      {
         param1.SetStyle(0,0,100);
         param1.DrawCircle(this.pos.x,this.pos.y,this.r);
         if(this.CUR_STATE != 0)
         {
            param1.DrawLine(this.pos.x,this.pos.y,this.pos.x + this.CUR_STATE * 8,this.pos.y);
         }
      }
   }
}

