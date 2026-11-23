package simulation.entities
{
   import audiovisual.entitygraphics.EntityGraphics;
   import audiovisual.entitygraphics.EntityGraphics_OnewayPlatform;
   import math.vec2;
   import simpleFramework.SimpleRenderer;
   import simulation.Simulator;
   import simulation.collision.Grid_Entity;
   import simulation.ninja.Ninja;
   
   public class Entity_OnewayPlatform extends Entity_Base
   {
      
      private var pos:vec2;
      
      private var n:vec2;
      
      private var r:Number;
      
      public function Entity_OnewayPlatform(param1:Grid_Entity, param2:Number, param3:Number, param4:Number, param5:Number)
      {
         super();
         this.pos = new vec2(param2,param3);
         this.n = new vec2(param4,param5);
         this.r = 12;
         param1.ENTITY_Add(this.pos,this);
      }
      
      override public function CollideVsCircle_Physical(param1:collision_result_physical, param2:vec2, param3:vec2, param4:vec2, param5:Number) : Boolean
      {
         var _loc6_:Number = NaN;
         _loc6_ = this.CalculatePenetration(param2,param3,param4,param5,0);
         if(_loc6_ >= 0)
         {
            param1.isHardCollision = true;
            param1.nx = this.n.x;
            param1.ny = this.n.y;
            param1.pen = _loc6_;
            return true;
         }
         return false;
      }
      
      override public function CollideVsCircle_Logical(param1:Simulator, param2:Ninja, param3:collision_result_logical, param4:vec2, param5:vec2, param6:vec2, param7:Number, param8:Number) : Boolean
      {
         var _loc9_:Number = NaN;
         if(param2 != null)
         {
            _loc9_ = this.CalculatePenetration(param4,param5,param6,param7,param8);
            if(_loc9_ >= 0)
            {
               param3.vec_x = this.n.x;
               param3.vec_y = this.n.y;
               return true;
            }
         }
         return false;
      }
      
      private function CalculatePenetration(param1:vec2, param2:vec2, param3:vec2, param4:Number, param5:Number) : Number
      {
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc6_:Number = param1.x - this.pos.x;
         var _loc7_:Number = param1.y - this.pos.y;
         var _loc8_:Number = this.r + param4 - Math.abs(-this.n.y * _loc6_ + this.n.x * _loc7_);
         if(0 < _loc8_)
         {
            _loc9_ = param4 + param5 - Math.abs(this.n.x * _loc6_ + this.n.y * _loc7_);
            if(0 < _loc9_)
            {
               _loc10_ = this.n.x * param2.x + this.n.y * param2.y;
               if(_loc10_ <= 0)
               {
                  _loc11_ = param3.x - this.pos.x;
                  _loc12_ = param3.y - this.pos.y;
                  _loc13_ = param4 - (this.n.x * _loc11_ + this.n.y * _loc12_);
                  if(_loc13_ <= 1.1)
                  {
                     _loc14_ = param4 - (this.n.x * _loc6_ + this.n.y * _loc7_);
                     if(_loc14_ < 0)
                     {
                        trace("WARNING! Entity_OnewayPlatform.CalculatePenetration() found conflicting penetration: " + _loc8_ + "," + _loc9_ + "," + _loc14_);
                        return -1;
                     }
                     return _loc14_;
                  }
               }
            }
         }
         return -1;
      }
      
      override public function GenerateGraphicComponent() : EntityGraphics
      {
         return new EntityGraphics_OnewayPlatform(this.pos.x,this.pos.y,Math.atan2(this.n.y,this.n.x));
      }
      
      override public function Debug_Draw(param1:SimpleRenderer) : void
      {
         param1.SetStyle(0,0,100);
         param1.DrawLine(this.pos.x - -this.n.y * this.r,this.pos.y - this.n.x * this.r,this.pos.x + -this.n.y * this.r,this.pos.y + this.n.x * this.r);
         param1.DrawLine(this.pos.x,this.pos.y,this.pos.x + this.n.x * 4,this.pos.y + this.n.y * 4);
      }
   }
}

