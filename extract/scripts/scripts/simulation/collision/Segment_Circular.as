package simulation.collision
{
   import math.vec2;
   import simpleFramework.SimpleRenderer;
   
   public class Segment_Circular implements Segment
   {
      
      private static const zero_vec:vec2 = new vec2(0,0);
      
      private static var cp:vec2 = new vec2();
      
      private static var ray_point:vec2 = new vec2();
      
      private var p0:vec2;
      
      private var p1:vec2;
      
      private var pC:vec2;
      
      private var aabb:AABB;
      
      public function Segment_Circular(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number)
      {
         super();
         this.p0 = new vec2(param3,param4);
         this.p1 = new vec2(param5,param6);
         this.pC = new vec2(param1,param2);
         this.aabb = new AABB(Math.min(this.p0.x,this.p1.x),Math.min(this.p0.y,this.p1.y),Math.max(this.p0.x,this.p1.x),Math.max(this.p0.y,this.p1.y));
      }
      
      public function GetAABB() : AABB
      {
         return this.aabb;
      }
      
      public function GetClosestPoint(param1:vec2, param2:vec2) : void
      {
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc3_:Number = this.p0.x - this.pC.x;
         var _loc4_:Number = this.p0.y - this.pC.y;
         var _loc5_:Number = this.p1.x - this.pC.x;
         var _loc6_:Number = this.p1.y - this.pC.y;
         var _loc7_:Number = param1.x - this.pC.x;
         var _loc8_:Number = param1.y - this.pC.y;
         var _loc9_:Number = _loc7_ * -_loc4_ + _loc8_ * _loc3_;
         var _loc10_:Number = _loc7_ * -_loc6_ + _loc8_ * _loc5_;
         var _loc11_:Number = this.p1.x - this.p0.x;
         var _loc12_:Number = this.p1.y - this.p0.y;
         var _loc13_:Number = _loc11_ * -_loc4_ + _loc12_ * _loc3_;
         var _loc14_:Number = _loc11_ * -_loc6_ + _loc12_ * _loc5_;
         var _loc15_:* = _loc9_ * _loc13_ <= 0;
         var _loc16_:* = _loc10_ * _loc14_ >= 0;
         if(_loc15_)
         {
            if(_loc16_)
            {
               if(_loc7_ * _loc11_ + _loc8_ * _loc12_ <= 0)
               {
                  param2.Copy(this.p0);
               }
               else
               {
                  param2.Copy(this.p1);
               }
            }
            else
            {
               param2.Copy(this.p0);
            }
         }
         else if(_loc16_)
         {
            param2.Copy(this.p1);
         }
         else
         {
            _loc17_ = Math.sqrt(_loc3_ * _loc3_ + _loc4_ * _loc4_);
            _loc18_ = Math.sqrt(_loc7_ * _loc7_ + _loc8_ * _loc8_);
            _loc7_ /= _loc18_;
            _loc8_ /= _loc18_;
            _loc7_ *= _loc17_;
            _loc8_ *= _loc17_;
            param2.x = this.pC.x + _loc7_;
            param2.y = this.pC.y + _loc8_;
         }
      }
      
      public function GetClosestPoint_IsBackfacing(param1:vec2, param2:vec2) : Boolean
      {
         var _loc20_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc3_:Number = this.p0.x - this.pC.x;
         var _loc4_:Number = this.p0.y - this.pC.y;
         var _loc5_:Number = this.p1.x - this.pC.x;
         var _loc6_:Number = this.p1.y - this.pC.y;
         var _loc7_:Number = param1.x - this.pC.x;
         var _loc8_:Number = param1.y - this.pC.y;
         var _loc9_:Number = _loc7_ * -_loc4_ + _loc8_ * _loc3_;
         var _loc10_:Number = _loc7_ * -_loc6_ + _loc8_ * _loc5_;
         var _loc11_:Number = this.p1.x - this.p0.x;
         var _loc12_:Number = this.p1.y - this.p0.y;
         var _loc13_:Number = _loc11_ * -_loc4_ + _loc12_ * _loc3_;
         var _loc14_:Number = _loc11_ * -_loc6_ + _loc12_ * _loc5_;
         var _loc15_:* = _loc9_ * _loc13_ <= 0;
         var _loc16_:* = _loc10_ * _loc14_ >= 0;
         var _loc17_:int = -1;
         if(_loc15_)
         {
            if(_loc16_)
            {
               if(_loc7_ * _loc11_ + _loc8_ * _loc12_ <= 0)
               {
                  param2.Copy(this.p0);
                  _loc17_ = 0;
               }
               else
               {
                  param2.Copy(this.p1);
                  _loc17_ = 1;
               }
            }
            else
            {
               param2.Copy(this.p0);
               _loc17_ = 0;
            }
         }
         else if(_loc16_)
         {
            param2.Copy(this.p1);
            _loc17_ = 1;
         }
         else
         {
            _loc20_ = Math.sqrt(_loc3_ * _loc3_ + _loc4_ * _loc4_);
            _loc21_ = Math.sqrt(_loc7_ * _loc7_ + _loc8_ * _loc8_);
            _loc7_ /= _loc21_;
            _loc8_ /= _loc21_;
            _loc7_ *= _loc20_;
            _loc8_ *= _loc20_;
            param2.x = this.pC.x + _loc7_;
            param2.y = this.pC.y + _loc8_;
         }
         var _loc18_:Number = param2.x - param1.x;
         var _loc19_:Number = param2.y - param1.y;
         if(_loc17_ < 0)
         {
            return _loc18_ * -_loc12_ + _loc19_ * _loc11_ > 0;
         }
         _loc22_ = _loc3_;
         _loc23_ = _loc4_;
         if(_loc17_ == 1)
         {
            _loc22_ = _loc5_;
            _loc23_ = _loc6_;
         }
         if(_loc22_ * -_loc12_ + _loc23_ * _loc11_ < 0)
         {
            _loc22_ *= -1;
            _loc23_ *= -1;
         }
         return _loc18_ * _loc22_ + _loc19_ * _loc23_ > 0;
      }
      
      public function IntersectWithRay(param1:vec2, param2:vec2, param3:Number, param4:vec2, param5:vec2) : Number
      {
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc6_:Number = colutils.TimeOfIntersection_Circle_vs_Circle(param1,param2,this.p0,zero_vec,param3);
         var _loc7_:Number = colutils.TimeOfIntersection_Circle_vs_Circle(param1,param2,this.p1,zero_vec,param3);
         var _loc8_:Number = 2;
         this.GetClosestPoint(param1,cp);
         var _loc9_:Number = param1.x - cp.x;
         var _loc10_:Number = param1.y - cp.y;
         var _loc11_:Number = Math.sqrt(_loc9_ * _loc9_ + _loc10_ * _loc10_);
         if(_loc11_ <= param3)
         {
            _loc8_ = -1;
         }
         else
         {
            _loc8_ = colutils.TimeOfIntersection_Circle_vs_Arc(param1,param2,this.pC,this.p0,this.p1,param3);
         }
         var _loc12_:Number = Math.min(_loc6_,_loc7_,_loc8_);
         if(_loc12_ <= 1 && _loc12_ >= 0)
         {
            ray_point.x = param1.x + _loc12_ * param2.x;
            ray_point.y = param1.y + _loc12_ * param2.y;
            if(param3 > 0)
            {
               this.GetClosestPoint(ray_point,cp);
               _loc13_ = ray_point.x - cp.x;
               _loc14_ = ray_point.y - cp.y;
               _loc15_ = Math.sqrt(_loc13_ * _loc13_ + _loc14_ * _loc14_);
               _loc13_ /= _loc15_;
               _loc14_ /= _loc15_;
               param4.x = cp.x;
               param4.y = cp.y;
               param5.x = _loc13_;
               param5.y = _loc14_;
            }
            else
            {
               _loc16_ = ray_point.x - this.pC.x;
               _loc17_ = ray_point.y - this.pC.y;
               _loc18_ = Math.sqrt(_loc16_ * _loc16_ + _loc17_ * _loc17_);
               _loc16_ /= _loc18_;
               _loc17_ /= _loc18_;
               if(_loc16_ * param2.x + _loc17_ * param2.y > 0)
               {
                  _loc16_ *= -1;
                  _loc17_ *= -1;
               }
               param4.Copy(ray_point);
               param5.x = _loc16_;
               param5.y = _loc17_;
            }
         }
         return _loc12_;
      }
      
      public function DebugDraw(param1:SimpleRenderer) : void
      {
         param1.SetStyle(0,0,100);
         this.DebugDraw_NoStyle(param1);
      }
      
      public function DebugDraw_Simple(param1:SimpleRenderer) : void
      {
         param1.DrawCircularArc_Convex(this.pC.x,this.pC.y,this.p0.x,this.p0.y,this.p1.x,this.p1.y,this.pC.To(this.p0).Len());
      }
      
      public function DebugDraw_NoStyle(param1:SimpleRenderer) : void
      {
         param1.DrawCircularArc_Convex(this.pC.x,this.pC.y,this.p0.x,this.p0.y,this.p1.x,this.p1.y,this.pC.To(this.p0).Len());
         param1.DrawSquare(this.p0.x,this.p0.y,2);
         param1.DrawSquare(this.p1.x,this.p1.y,2);
         param1.DrawPlus(this.pC.x,this.pC.y,2);
         var _loc2_:Number = this.pC.To(this.p0).Len();
         var _loc3_:vec2 = this.p0.To(this.p1);
         var _loc4_:vec2 = _loc3_.Perp();
         _loc4_.Normalize();
         _loc3_.Scale(0.5);
         var _loc5_:vec2 = this.pC.To(this.p0.Plus(_loc3_));
         _loc5_.Normalize();
         _loc5_.Scale(_loc2_);
         param1.DrawLine(this.pC.x + _loc5_.x,this.pC.y + _loc5_.y,this.pC.x + _loc5_.x + 4 * _loc4_.x,this.pC.y + _loc5_.y + 4 * _loc4_.y);
      }
   }
}

