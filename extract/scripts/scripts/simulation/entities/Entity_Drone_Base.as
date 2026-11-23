package simulation.entities
{
   import math.mathutils;
   import math.vec2;
   import simpleFramework.SimpleRenderer;
   import simulation.Simulator;
   import simulation.collision.Grid_Edges;
   import simulation.collision.Grid_Entity;
   import simulation.collision.Grid_Segment;
   import simulation.ninja.Ninja;
   
   public class Entity_Drone_Base extends Entity_Base
   {
      
      protected static const DIR_R:uint = 0;
      
      protected static const DIR_D:uint = 1;
      
      protected static const DIR_L:uint = 2;
      
      protected static const DIR_U:uint = 3;
      
      protected static const DIR_TO_VEC2:Vector.<vec2> = new Vector.<vec2>(4,true);
      
      protected static const DIR_TO_RAD:Vector.<Number> = new Vector.<Number>(4,true);
      
      protected static const ROT_0:uint = 0;
      
      protected static const ROT_90:uint = 1;
      
      protected static const ROT_180:uint = 2;
      
      protected static const ROT_270:uint = 3;
      
      protected static const MOVETYPE_SURFACE_CW:uint = 0;
      
      protected static const MOVETYPE_SURFACE_CCW:uint = 1;
      
      protected static const MOVETYPE_WANDER_CW:uint = 2;
      
      protected static const MOVETYPE_WANDER_CCW:uint = 3;
      
      protected static const MOVELIST:Vector.<Vector.<uint>> = new Vector.<Vector.<uint>>(4,true);
      
      DIR_TO_VEC2[DIR_R] = new vec2(1,0);
      DIR_TO_VEC2[DIR_D] = new vec2(0,1);
      DIR_TO_VEC2[DIR_L] = new vec2(-1,0);
      DIR_TO_VEC2[DIR_U] = new vec2(0,-1);
      DIR_TO_RAD[DIR_R] = 0 * Math.PI;
      DIR_TO_RAD[DIR_D] = 0.5 * Math.PI;
      DIR_TO_RAD[DIR_L] = 1 * Math.PI;
      DIR_TO_RAD[DIR_U] = 1.5 * Math.PI;
      MOVELIST[MOVETYPE_SURFACE_CW] = new Vector.<uint>(4,true);
      MOVELIST[MOVETYPE_SURFACE_CW][0] = ROT_90;
      MOVELIST[MOVETYPE_SURFACE_CW][1] = ROT_0;
      MOVELIST[MOVETYPE_SURFACE_CW][2] = ROT_270;
      MOVELIST[MOVETYPE_SURFACE_CW][3] = ROT_180;
      MOVELIST[MOVETYPE_SURFACE_CCW] = new Vector.<uint>(4,true);
      MOVELIST[MOVETYPE_SURFACE_CCW][0] = ROT_270;
      MOVELIST[MOVETYPE_SURFACE_CCW][1] = ROT_0;
      MOVELIST[MOVETYPE_SURFACE_CCW][2] = ROT_90;
      MOVELIST[MOVETYPE_SURFACE_CCW][3] = ROT_180;
      MOVELIST[MOVETYPE_WANDER_CW] = new Vector.<uint>(4,true);
      MOVELIST[MOVETYPE_WANDER_CW][0] = ROT_0;
      MOVELIST[MOVETYPE_WANDER_CW][1] = ROT_90;
      MOVELIST[MOVETYPE_WANDER_CW][2] = ROT_270;
      MOVELIST[MOVETYPE_WANDER_CW][3] = ROT_180;
      MOVELIST[MOVETYPE_WANDER_CCW] = new Vector.<uint>(4,true);
      MOVELIST[MOVETYPE_WANDER_CCW][0] = ROT_0;
      MOVELIST[MOVETYPE_WANDER_CCW][1] = ROT_270;
      MOVELIST[MOVETYPE_WANDER_CCW][2] = ROT_90;
      MOVELIST[MOVETYPE_WANDER_CCW][3] = ROT_180;
      
      protected var pos:vec2;
      
      protected var speed:Number;
      
      protected var r:Number;
      
      protected var gfxorn:Number;
      
      private var step_size:Number;
      
      protected var next_goal:vec2;
      
      protected var facing_DIR:uint;
      
      protected var move_TYPE:uint;
      
      public function Entity_Drone_Base(param1:Grid_Entity, param2:Number, param3:Number, param4:Number, param5:uint, param6:uint)
      {
         super();
         this.pos = new vec2(param2,param3);
         this.r = 12 * (3 / 4);
         this.speed = param4;
         this.step_size = 24;
         this.next_goal = this.pos.Clone();
         this.facing_DIR = param5;
         this.move_TYPE = param6;
         this.gfxorn = DIR_TO_RAD[this.facing_DIR];
         param1.ENTITY_Add(this.pos,this);
      }
      
      override public function Move(param1:Simulator) : void
      {
         this.Move_Forward(param1.edgeGrid,param1.segGrid,param1.objGrid,param1.playerList);
         var _loc2_:Number = DIR_TO_RAD[this.facing_DIR];
         var _loc3_:Number = mathutils.WrapAngle_Shortest(_loc2_ - this.gfxorn);
         this.gfxorn = mathutils.WrapAngle_Pos(this.gfxorn + 0.3 * _loc3_);
      }
      
      private function Move_Forward(param1:Grid_Edges, param2:Grid_Segment, param3:Grid_Entity, param4:Vector.<Ninja>) : void
      {
         var _loc16_:Number = NaN;
         var _loc17_:vec2 = null;
         var _loc5_:vec2 = DIR_TO_VEC2[this.facing_DIR];
         var _loc6_:Number = _loc5_.x * this.speed;
         var _loc7_:Number = _loc5_.y * this.speed;
         var _loc8_:Number = this.pos.x + _loc6_;
         var _loc9_:Number = this.pos.y + _loc7_;
         var _loc10_:Number = this.next_goal.x - this.pos.x;
         var _loc11_:Number = this.next_goal.y - this.pos.y;
         var _loc12_:Number = this.next_goal.x - _loc8_;
         var _loc13_:Number = this.next_goal.y - _loc9_;
         var _loc14_:Number = Math.sqrt(_loc10_ * _loc10_ + _loc11_ * _loc11_);
         var _loc15_:Number = _loc10_ * _loc12_ + _loc11_ * _loc13_;
         if(_loc14_ < 0.000001 || _loc15_ < 0)
         {
            this.pos.Copy(this.next_goal);
            if(this.ChooseNextDirAndGoal(param1,param4))
            {
               _loc16_ = Math.max(0,this.speed - _loc14_);
               _loc17_ = DIR_TO_VEC2[this.facing_DIR];
               this.pos.x += _loc17_.x * _loc16_;
               this.pos.y += _loc17_.y * _loc16_;
            }
         }
         else
         {
            this.pos.x += _loc6_;
            this.pos.y += _loc7_;
         }
         param3.ENTITY_Move(this.pos,this);
      }
      
      protected function ChooseNextDirAndGoal(param1:Grid_Edges, param2:Vector.<Ninja>) : Boolean
      {
         var _loc4_:uint = 0;
         var _loc3_:int = 0;
         while(_loc3_ < 4)
         {
            _loc4_ = (this.facing_DIR + MOVELIST[this.move_TYPE][_loc3_]) % 4;
            if(this.ChooseNextDirAndGoal_HELPER_TestDir(param1,_loc4_,this.next_goal))
            {
               this.facing_DIR = _loc4_;
               return true;
            }
            _loc3_++;
         }
         return false;
      }
      
      protected function ChooseNextDirAndGoal_HELPER_TestDir(param1:Grid_Edges, param2:uint, param3:vec2) : Boolean
      {
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc4_:vec2 = DIR_TO_VEC2[param2];
         var _loc5_:Number = this.pos.x + _loc4_.x * this.step_size;
         var _loc6_:Number = this.pos.y + _loc4_.y * this.step_size;
         if(_loc4_.y == 0)
         {
            _loc7_ = param1.GetGridCoordinateFromWorldspace_1D(this.pos.x + _loc4_.x * this.r);
            _loc8_ = param1.GetGridCoordinateFromWorldspace_1D(_loc5_ + _loc4_.x * this.r);
            _loc9_ = param1.GetGridCoordinateFromWorldspace_1D(this.pos.y - this.r);
            _loc10_ = param1.GetGridCoordinateFromWorldspace_1D(this.pos.y + this.r);
            if(!param1.ScanHorizontal_Directed(_loc9_,_loc10_,_loc7_,_loc8_,_loc4_.x))
            {
               return false;
            }
         }
         else
         {
            if(_loc4_.x != 0)
            {
               trace("WARNING! ChooseNextDirAndGoal_HELPER_TestDir() has a non-axis-aligned search vector: " + _loc4_.ToString());
               return false;
            }
            _loc11_ = param1.GetGridCoordinateFromWorldspace_1D(this.pos.y + _loc4_.y * this.r);
            _loc12_ = param1.GetGridCoordinateFromWorldspace_1D(_loc6_ + _loc4_.y * this.r);
            _loc13_ = param1.GetGridCoordinateFromWorldspace_1D(this.pos.x - this.r);
            _loc14_ = param1.GetGridCoordinateFromWorldspace_1D(this.pos.x + this.r);
            if(!param1.ScanVertical_Directed(_loc13_,_loc14_,_loc11_,_loc12_,_loc4_.y))
            {
               return false;
            }
         }
         param3.x = _loc5_;
         param3.y = _loc6_;
         return true;
      }
      
      override public function Debug_Draw(param1:SimpleRenderer) : void
      {
         param1.SetStyle(0,0,100);
         param1.DrawCircle(this.pos.x,this.pos.y,this.r);
         var _loc2_:vec2 = new vec2(Math.cos(this.gfxorn),Math.sin(this.gfxorn));
         param1.DrawLine(this.pos.x,this.pos.y,this.pos.x + _loc2_.x * 8,this.pos.y + _loc2_.y * 8);
      }
   }
}

