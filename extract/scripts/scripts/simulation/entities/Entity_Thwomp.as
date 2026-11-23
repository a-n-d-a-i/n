package simulation.entities
{
   import audiovisual.entitygraphics.EntityGraphics;
   import audiovisual.entitygraphics.EntityGraphics_Thwomp;
   import math.vec2;
   import simpleFramework.SimpleRenderer;
   import simulation.Simulator;
   import simulation.collision.Grid_Edges;
   import simulation.collision.Grid_Entity;
   import simulation.collision.colutils;
   import simulation.ninja.Ninja;
   import simulation.sim_globals;
   
   public class Entity_Thwomp extends Entity_Base
   {
      
      private var pos:vec2;
      
      private var anchor:vec2;
      
      private var r:Number;
      
      private var fallspeed:Number;
      
      private var raisespeed:Number;
      
      private var CUR_STATE:int;
      
      private var falldir:int;
      
      private var isHorizontal:Boolean;
      
      private var n:vec2;
      
      public function Entity_Thwomp(param1:Grid_Entity, param2:Number, param3:Number, param4:int, param5:Boolean)
      {
         super();
         this.pos = new vec2(param2,param3);
         this.anchor = new vec2(param2,param3);
         this.r = 12 * (3 / 4);
         this.fallspeed = 12 * (5 / 14) * (40 / sim_globals.sim_rate);
         this.raisespeed = 12 * (1 / 7) * (40 / sim_globals.sim_rate);
         this.CUR_STATE = 0;
         this.falldir = param4;
         this.isHorizontal = param5;
         param1.ENTITY_Add(this.pos,this);
         this.n = new vec2();
      }
      
      override public function CollideVsCircle_Physical(param1:collision_result_physical, param2:vec2, param3:vec2, param4:vec2, param5:Number) : Boolean
      {
         this.n.x = 0;
         this.n.y = 0;
         var _loc6_:Number = colutils.Penetration_Square_vs_Point(this.pos,this.r + param5,param2,this.n);
         if(_loc6_ != 0)
         {
            param1.isHardCollision = false;
            param1.nx = this.n.x;
            param1.ny = this.n.y;
            param1.pen = _loc6_;
            return true;
         }
         return false;
      }
      
      override public function CollideVsCircle_Logical(param1:Simulator, param2:Ninja, param3:collision_result_logical, param4:vec2, param5:vec2, param6:vec2, param7:Number, param8:Number) : Boolean
      {
         param8 = 0.1;
         this.n.x = 0;
         this.n.y = 0;
         var _loc9_:Number = colutils.Penetration_Square_vs_Point(this.pos,param8 + this.r + param7,param4,this.n);
         if(_loc9_ != 0)
         {
            if(this.isHorizontal && this.n.x * this.falldir > 0 || !this.isHorizontal && this.n.y * this.falldir > 0)
            {
               if(this.isHorizontal)
               {
                  param1.HACKY_GetParticleManager().Spawn_ZapThwompH(this.pos,this.r * this.falldir,this.r);
               }
               else
               {
                  param1.HACKY_GetParticleManager().Spawn_ZapThwompV(this.pos,this.r,this.r * this.falldir);
               }
               if(param2 == null)
               {
                  param3.vec_x = this.n.x * 8;
                  param3.vec_y = this.n.y * 8 - 4;
                  return true;
               }
               param1.Event_PlayerWasKilled(param2,sim_globals.ENEMYTYPE_THWOMP,param4.x - this.n.x * param7,param4.y - this.n.y * param7,this.n.x * 8,this.n.y * 8 - 4);
            }
            else if(param2 != null)
            {
               param3.vec_x = this.n.x;
               param3.vec_y = this.n.y;
               return true;
            }
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
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc17_:int = 0;
         var _loc18_:int = 0;
         var _loc19_:int = 0;
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
                  _loc6_ = _loc4_.GetRadius();
                  _loc7_ = _loc5_.x - this.pos.x;
                  _loc8_ = _loc5_.y - this.pos.y;
                  _loc9_ = 2 * (this.r + _loc6_);
                  if(this.isHorizontal)
                  {
                     if(Math.abs(_loc8_) < _loc9_)
                     {
                        _loc10_ = _loc2_.GetGridCoordinateFromWorldspace_1D(this.pos.x - this.falldir * this.r);
                        _loc11_ = _loc2_.GetGridCoordinateFromWorldspace_1D(this.pos.y - this.r);
                        _loc12_ = _loc2_.GetGridCoordinateFromWorldspace_1D(this.pos.y + this.r);
                        _loc13_ = _loc2_.SweepHorizontal(_loc11_,_loc12_,_loc10_,this.falldir);
                        _loc14_ = _loc2_.GetGridCoordinateFromWorldspace_1D(_loc5_.x);
                        if(!(_loc14_ < Math.min(_loc10_,_loc13_) || _loc14_ > Math.max(_loc10_,_loc13_)))
                        {
                           this.CUR_STATE = 1;
                           break;
                        }
                     }
                  }
                  else if(Math.abs(_loc7_) < _loc9_)
                  {
                     _loc15_ = _loc2_.GetGridCoordinateFromWorldspace_1D(this.pos.y - this.falldir * this.r);
                     _loc16_ = _loc2_.GetGridCoordinateFromWorldspace_1D(this.pos.x - this.r);
                     _loc17_ = _loc2_.GetGridCoordinateFromWorldspace_1D(this.pos.x + this.r);
                     _loc18_ = _loc2_.SweepVertical(_loc16_,_loc17_,_loc15_,this.falldir);
                     _loc19_ = _loc2_.GetGridCoordinateFromWorldspace_1D(_loc5_.y);
                     if(!(_loc19_ < Math.min(_loc15_,_loc18_) || _loc19_ > Math.max(_loc15_,_loc18_)))
                     {
                        this.CUR_STATE = 1;
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
         var _loc6_:Number = NaN;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:Number = NaN;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         if(this.CUR_STATE == 0)
         {
            return;
         }
         var _loc2_:Grid_Edges = param1.edgeGrid;
         var _loc3_:int = this.falldir * this.CUR_STATE;
         var _loc4_:Number = _loc3_ * this.r;
         var _loc5_:Number = this.fallspeed;
         if(this.CUR_STATE == -1)
         {
            _loc5_ = this.raisespeed;
         }
         if(this.isHorizontal)
         {
            _loc6_ = this.pos.x + _loc3_ * _loc5_;
            if(this.CUR_STATE == -1)
            {
               if((this.pos.x - this.anchor.x) * (_loc6_ - this.anchor.x) <= 0)
               {
                  _loc6_ = this.anchor.x;
               }
            }
            _loc7_ = _loc2_.GetGridCoordinateFromWorldspace_1D(this.pos.x + _loc4_);
            _loc8_ = _loc2_.GetGridCoordinateFromWorldspace_1D(_loc6_ + _loc4_);
            if(_loc7_ != _loc8_)
            {
               _loc9_ = _loc2_.GetGridCoordinateFromWorldspace_1D(this.pos.y - this.r);
               _loc10_ = _loc2_.GetGridCoordinateFromWorldspace_1D(this.pos.y + this.r);
               if(!_loc2_.IsEmpty_Column(_loc7_,_loc9_,_loc10_,_loc3_))
               {
                  if(this.CUR_STATE != -1)
                  {
                     this.CUR_STATE = -1;
                  }
                  return;
               }
            }
            this.pos.x = _loc6_;
            param1.objGrid.ENTITY_Move(this.pos,this);
            if(this.CUR_STATE == -1 && this.pos.x == this.anchor.x)
            {
               this.CUR_STATE = 0;
            }
         }
         else
         {
            _loc11_ = this.pos.y + _loc3_ * _loc5_;
            if(this.CUR_STATE == -1)
            {
               if((this.pos.y - this.anchor.y) * (_loc11_ - this.anchor.y) <= 0)
               {
                  _loc11_ = this.anchor.y;
               }
            }
            _loc12_ = _loc2_.GetGridCoordinateFromWorldspace_1D(this.pos.y + _loc4_);
            _loc13_ = _loc2_.GetGridCoordinateFromWorldspace_1D(_loc11_ + _loc4_);
            if(_loc12_ != _loc13_)
            {
               _loc14_ = _loc2_.GetGridCoordinateFromWorldspace_1D(this.pos.x - this.r);
               _loc15_ = _loc2_.GetGridCoordinateFromWorldspace_1D(this.pos.x + this.r);
               if(!_loc2_.IsEmpty_Row(_loc12_,_loc14_,_loc15_,_loc3_))
               {
                  if(this.CUR_STATE != -1)
                  {
                     this.CUR_STATE = -1;
                  }
                  return;
               }
            }
            this.pos.y = _loc11_;
            param1.objGrid.ENTITY_Move(this.pos,this);
            if(this.CUR_STATE == -1 && this.pos.y == this.anchor.y)
            {
               this.CUR_STATE = 0;
            }
         }
      }
      
      override public function GenerateGraphicComponent() : EntityGraphics
      {
         var _loc1_:Number = 0;
         if(this.isHorizontal)
         {
            if(this.falldir < 0)
            {
               _loc1_ = Math.PI;
            }
         }
         else if(this.falldir < 0)
         {
            _loc1_ = 1.5 * Math.PI;
         }
         else
         {
            _loc1_ = 0.5 * Math.PI;
         }
         return new EntityGraphics_Thwomp(this,_loc1_);
      }
      
      public function GFX_UpdateState(param1:EntityGraphics_Thwomp) : void
      {
         param1.pos.x = this.pos.x;
         param1.pos.y = this.pos.y;
      }
      
      override public function Debug_Draw(param1:SimpleRenderer) : void
      {
         param1.SetStyle(0,0,100);
         param1.DrawSquare(this.pos.x,this.pos.y,this.r);
         var _loc2_:int = -4;
         while(_loc2_ <= 4)
         {
            if(this.isHorizontal)
            {
               param1.DrawLine(this.pos.x + this.falldir * this.r - 2,this.pos.y + _loc2_,this.pos.x + this.falldir * this.r + 2,this.pos.y + _loc2_);
            }
            else
            {
               param1.DrawLine(this.pos.x + _loc2_,this.pos.y + this.falldir * this.r - 2,this.pos.x + _loc2_,this.pos.y + this.falldir * this.r + 2);
            }
            _loc2_ += 4;
         }
         if(this.CUR_STATE != 0)
         {
            if(this.isHorizontal)
            {
               param1.DrawLine(this.pos.x,this.pos.y,this.pos.x + this.falldir * this.CUR_STATE * 8,this.pos.y);
            }
            else
            {
               param1.DrawLine(this.pos.x,this.pos.y,this.pos.x,this.pos.y + this.falldir * this.CUR_STATE * 8);
            }
         }
      }
   }
}

