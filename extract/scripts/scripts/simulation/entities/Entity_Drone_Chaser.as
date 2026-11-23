package simulation.entities
{
   import audiovisual.entitygraphics.EntityGraphics;
   import audiovisual.entitygraphics.EntityGraphics_Drone_Chaser;
   import math.vec2;
   import simpleFramework.SimpleRenderer;
   import simulation.Simulator;
   import simulation.collision.Grid_Edges;
   import simulation.collision.Grid_Entity;
   import simulation.ninja.Ninja;
   
   public class Entity_Drone_Chaser extends Entity_Drone_Zap
   {
      
      private var isChasing:Boolean;
      
      private var speed_regular:Number;
      
      private var speed_chasing:Number;
      
      private var old_chase_DIR:int;
      
      private var gfx_startedChasing:Boolean;
      
      public function Entity_Drone_Chaser(param1:Grid_Entity, param2:Number, param3:Number, param4:uint, param5:uint)
      {
         super(param1,param2,param3,param4,param5);
         this.isChasing = false;
         this.speed_regular = speed;
         this.speed_chasing = this.speed_regular * 2;
         this.gfx_startedChasing = false;
         this.old_chase_DIR = -1;
      }
      
      override public function Think(param1:Simulator) : void
      {
      }
      
      private function StartChasing(param1:uint) : void
      {
         facing_DIR = param1;
         speed = this.speed_chasing;
         this.isChasing = true;
         this.gfx_startedChasing = true;
      }
      
      private function StopChasing(param1:uint) : void
      {
         this.old_chase_DIR = facing_DIR;
         facing_DIR = param1;
         speed = this.speed_regular;
         this.isChasing = false;
      }
      
      override protected function ChooseNextDirAndGoal(param1:Grid_Edges, param2:Vector.<Ninja>) : Boolean
      {
         var _loc5_:uint = 0;
         var _loc6_:vec2 = null;
         var _loc7_:int = 0;
         var _loc8_:uint = 0;
         var _loc9_:vec2 = null;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Boolean = false;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc17_:int = 0;
         var _loc18_:int = 0;
         var _loc19_:int = 0;
         var _loc20_:int = 0;
         var _loc21_:int = 0;
         if(this.isChasing)
         {
            if(ChooseNextDirAndGoal_HELPER_TestDir(param1,facing_DIR,next_goal))
            {
               return true;
            }
            _loc5_ = (facing_DIR - MOVELIST[move_TYPE][0] + 4) % 4;
            this.StopChasing(_loc5_);
         }
         var _loc3_:uint = facing_DIR;
         if(this.old_chase_DIR != -1)
         {
            _loc3_ = uint(this.old_chase_DIR);
            this.old_chase_DIR = -1;
         }
         var _loc4_:int = 0;
         while(_loc4_ < param2.length)
         {
            if(!param2[_loc4_].IsDead())
            {
               _loc6_ = param2[_loc4_].GetPos();
               _loc7_ = -1;
               for(; _loc7_ <= 1; _loc7_++)
               {
                  _loc8_ = uint(int((_loc3_ + _loc7_ + 4) % 4));
                  _loc9_ = DIR_TO_VEC2[_loc8_];
                  _loc10_ = _loc6_.x - pos.x;
                  _loc11_ = _loc6_.y - pos.y;
                  if(_loc9_.x * _loc10_ + _loc9_.y * _loc11_ > 0)
                  {
                     if(Math.abs(-_loc9_.y * _loc10_ + _loc9_.x * _loc11_) <= 12)
                     {
                        _loc12_ = true;
                        _loc13_ = 1;
                        if(_loc8_ % 2 == 1)
                        {
                           _loc12_ = false;
                        }
                        if(_loc8_ >= 2)
                        {
                           _loc13_ = -1;
                        }
                        if(_loc12_)
                        {
                           _loc14_ = param1.GetGridCoordinateFromWorldspace_1D(pos.x);
                           _loc15_ = param1.GetGridCoordinateFromWorldspace_1D(pos.y);
                           _loc16_ = param1.SweepHorizontal(_loc15_,_loc15_,_loc14_,_loc13_);
                           _loc17_ = param1.GetGridCoordinateFromWorldspace_1D(_loc6_.x);
                           if(_loc17_ < Math.min(_loc14_,_loc16_) || _loc17_ > Math.max(_loc14_,_loc16_))
                           {
                              continue;
                           }
                        }
                        else
                        {
                           _loc18_ = param1.GetGridCoordinateFromWorldspace_1D(pos.y);
                           _loc19_ = param1.GetGridCoordinateFromWorldspace_1D(pos.x);
                           _loc20_ = param1.SweepVertical(_loc19_,_loc19_,_loc18_,_loc13_);
                           _loc21_ = param1.GetGridCoordinateFromWorldspace_1D(_loc6_.y);
                           if(_loc21_ < Math.min(_loc18_,_loc20_) || _loc21_ > Math.max(_loc18_,_loc20_))
                           {
                              continue;
                           }
                        }
                        if(ChooseNextDirAndGoal_HELPER_TestDir(param1,_loc8_,next_goal))
                        {
                           this.StartChasing(_loc8_);
                           return true;
                        }
                     }
                  }
               }
            }
            _loc4_++;
         }
         return super.ChooseNextDirAndGoal(param1,param2);
      }
      
      override public function GenerateGraphicComponent() : EntityGraphics
      {
         return new EntityGraphics_Drone_Chaser(this);
      }
      
      override public function GFX_UpdateState(param1:EntityGraphics) : void
      {
         var _loc2_:EntityGraphics_Drone_Chaser = param1 as EntityGraphics_Drone_Chaser;
         _loc2_.pos.x = pos.x;
         _loc2_.pos.y = pos.y;
         _loc2_.orn = gfxorn;
         if(this.gfx_startedChasing)
         {
            this.gfx_startedChasing = false;
            _loc2_.anim = EntityGraphics_Drone_Chaser.ANIM_CHASE;
         }
         else
         {
            _loc2_.anim = EntityGraphics_Drone_Chaser.ANIM_IDLE;
         }
      }
      
      override public function Debug_Draw(param1:SimpleRenderer) : void
      {
         super.Debug_Draw(param1);
         var _loc2_:Number = pos.x + Math.SQRT1_2 * r;
         var _loc3_:Number = pos.y - Math.SQRT1_2 * r;
         if(this.isChasing)
         {
            param1.SetStyle(2,0,100);
         }
         else
         {
            param1.SetStyle(0,0,100);
         }
         param1.DrawLine(_loc2_,_loc3_,_loc2_,_loc3_ - 8);
      }
   }
}

