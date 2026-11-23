package simulation.collision
{
   import math.vec2;
   import simpleFramework.SimpleRenderer;
   
   public class Segment_Linear implements Segment
   {
      
      protected static const zero_vec:vec2 = new vec2(0,0);
      
      protected static var cp:vec2 = new vec2();
      
      protected static var ray_point:vec2 = new vec2();
      
      protected var p0:vec2;
      
      protected var p1:vec2;
      
      private var aabb:AABB;
      
      public function Segment_Linear(param1:Number, param2:Number, param3:Number, param4:Number)
      {
         super();
         this.p0 = new vec2(param1,param2);
         this.p1 = new vec2(param3,param4);
         this.aabb = new AABB(Math.min(this.p0.x,this.p1.x),Math.min(this.p0.y,this.p1.y),Math.max(this.p0.x,this.p1.x),Math.max(this.p0.y,this.p1.y));
      }
      
      public function GetAABB() : AABB
      {
         return this.aabb;
      }
      
      public function GetClosestPoint(param1:vec2, param2:vec2) : void
      {
         var _loc9_:Number = NaN;
         var _loc3_:Number = this.p1.x - this.p0.x;
         var _loc4_:Number = this.p1.y - this.p0.y;
         var _loc5_:Number = param1.x - this.p0.x;
         var _loc6_:Number = param1.y - this.p0.y;
         var _loc7_:Number = _loc3_ * _loc5_ + _loc4_ * _loc6_;
         var _loc8_:Number = _loc3_ * _loc3_ + _loc4_ * _loc4_;
         if(_loc7_ <= 0)
         {
            param2.Copy(this.p0);
         }
         else if(_loc7_ >= _loc8_)
         {
            param2.Copy(this.p1);
         }
         else
         {
            _loc9_ = _loc7_ / _loc8_;
            param2.x = this.p0.x + _loc9_ * _loc3_;
            param2.y = this.p0.y + _loc9_ * _loc4_;
         }
      }
      
      public function GetClosestPoint_IsBackfacing(param1:vec2, param2:vec2) : Boolean
      {
         var _loc9_:Number = NaN;
         var _loc3_:Number = this.p1.x - this.p0.x;
         var _loc4_:Number = this.p1.y - this.p0.y;
         var _loc5_:Number = param1.x - this.p0.x;
         var _loc6_:Number = param1.y - this.p0.y;
         var _loc7_:Number = _loc3_ * _loc5_ + _loc4_ * _loc6_;
         var _loc8_:Number = _loc3_ * _loc3_ + _loc4_ * _loc4_;
         if(_loc7_ <= 0)
         {
            param2.Copy(this.p0);
         }
         else if(_loc7_ >= _loc8_)
         {
            param2.Copy(this.p1);
         }
         else
         {
            _loc9_ = _loc7_ / _loc8_;
            param2.x = this.p0.x + _loc9_ * _loc3_;
            param2.y = this.p0.y + _loc9_ * _loc4_;
         }
         return _loc5_ * -_loc4_ + _loc6_ * _loc3_ < 0;
      }
      
      public function IntersectWithRay(param1:vec2, param2:vec2, param3:Number, param4:vec2, param5:vec2) : Number
      {
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc6_:Number = colutils.TimeOfIntersection_Circle_vs_Circle(param1,param2,this.p0,zero_vec,param3);
         var _loc7_:Number = colutils.TimeOfIntersection_Circle_vs_Circle(param1,param2,this.p1,zero_vec,param3);
         var _loc8_:Number = colutils.TimeOfIntersection_Point_vs_Lineseg(param1,param2,this.p0,this.p1,param3);
         var _loc9_:Number = Math.min(_loc6_,_loc7_,_loc8_);
         if(_loc9_ <= 1 && _loc9_ >= 0)
         {
            ray_point.x = param1.x + _loc9_ * param2.x;
            ray_point.y = param1.y + _loc9_ * param2.y;
            if(param3 > 0)
            {
               cp.x = 0;
               cp.y = 0;
               this.GetClosestPoint(ray_point,cp);
               _loc10_ = ray_point.x - cp.x;
               _loc11_ = ray_point.y - cp.y;
               _loc12_ = Math.sqrt(_loc10_ * _loc10_ + _loc11_ * _loc11_);
               _loc10_ /= _loc12_;
               _loc11_ /= _loc12_;
               param4.x = cp.x;
               param4.y = cp.y;
               param5.x = _loc10_;
               param5.y = _loc11_;
            }
            else
            {
               _loc13_ = -(this.p1.y - this.p0.y);
               _loc14_ = this.p1.x - this.p0.x;
               _loc15_ = Math.sqrt(_loc13_ * _loc13_ + _loc14_ * _loc14_);
               _loc13_ /= _loc15_;
               _loc14_ /= _loc15_;
               if(_loc13_ * param2.x + _loc14_ * param2.y > 0)
               {
                  _loc13_ *= -1;
                  _loc14_ *= -1;
               }
               param4.Copy(ray_point);
               param5.x = _loc13_;
               param5.y = _loc14_;
            }
         }
         return _loc9_;
      }
      
      public function DebugDraw(param1:SimpleRenderer) : void
      {
         param1.SetStyle(0,0,100);
         this.DebugDraw_NoStyle(param1);
      }
      
      public function DebugDraw_Simple(param1:SimpleRenderer) : void
      {
         param1.DrawLine(this.p0.x,this.p0.y,this.p1.x,this.p1.y);
      }
      
      public function DebugDraw_NoStyle(param1:SimpleRenderer) : void
      {
         param1.DrawLine(this.p0.x,this.p0.y,this.p1.x,this.p1.y);
         param1.DrawSquare(this.p0.x,this.p0.y,2);
         param1.DrawSquare(this.p1.x,this.p1.y,2);
         var _loc2_:vec2 = this.p0.To(this.p1);
         var _loc3_:vec2 = _loc2_.Perp();
         _loc3_.Normalize();
         param1.DrawLine(this.p0.x + 0.5 * _loc2_.x,this.p0.y + 0.5 * _loc2_.y,this.p0.x + 0.5 * _loc2_.x + 4 * _loc3_.x,this.p0.y + 0.5 * _loc2_.y + 4 * _loc3_.y);
      }
   }
}

