package simulation.collision
{
   import math.vec2;
   
   public class colutils
   {
      
      private static var cp:vec2 = new vec2();
      
      private static var segList:Vector.<Segment> = new Vector.<Segment>();
      
      public function colutils()
      {
         super();
      }
      
      public static function GetSingleClosestPoint_Signed(param1:Grid_Segment, param2:vec2, param3:Number, param4:vec2) : int
      {
         var _loc8_:Boolean = false;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc5_:int = 0;
         var _loc6_:Number = 99999999;
         param1.GatherCellContentsFromWorldspaceRegion(param2.x - param3,param2.y - param3,param2.x + param3,param2.y + param3,segList);
         var _loc7_:int = 0;
         while(_loc7_ < segList.length)
         {
            _loc8_ = segList[_loc7_].GetClosestPoint_IsBackfacing(param2,cp);
            _loc9_ = cp.x - param2.x;
            _loc10_ = cp.y - param2.y;
            _loc11_ = _loc9_ * _loc9_ + _loc10_ * _loc10_;
            if(!_loc8_)
            {
               _loc11_ -= 0.1;
            }
            if(_loc11_ < _loc6_)
            {
               param4.Copy(cp);
               _loc6_ = _loc11_;
               if(_loc8_)
               {
                  _loc5_ = -1;
               }
               else
               {
                  _loc5_ = 1;
               }
            }
            _loc7_++;
         }
         return _loc5_;
      }
      
      public static function Penetration_Square_vs_Point(param1:vec2, param2:Number, param3:vec2, param4:vec2) : Number
      {
         var _loc5_:Number = NaN;
         var _loc8_:Number = NaN;
         _loc5_ = param3.x - param1.x;
         var _loc6_:Number = param3.y - param1.y;
         var _loc7_:Number = param2 - Math.abs(_loc6_);
         if(0 < _loc7_)
         {
            _loc8_ = param2 - Math.abs(_loc5_);
            if(0 < _loc8_)
            {
               if(_loc7_ <= _loc8_)
               {
                  param4.x = 0;
                  param4.y = 1;
                  if(_loc6_ <= 0)
                  {
                     param4.y = -1;
                  }
                  return _loc7_;
               }
               param4.y = 0;
               param4.x = 1;
               if(_loc5_ <= 0)
               {
                  param4.x = -1;
               }
               return _loc8_;
            }
         }
         return 0;
      }
      
      public static function Overlap_Circle_Vs_Segment(param1:vec2, param2:Number, param3:vec2, param4:vec2, param5:Number) : Boolean
      {
         var _loc6_:Number = param1.x - param3.x;
         var _loc7_:Number = param1.y - param3.y;
         var _loc8_:Number = (param4.x - param3.x) / param5;
         var _loc9_:Number = (param4.y - param3.y) / param5;
         var _loc10_:Number = _loc6_ * _loc8_ + _loc7_ * _loc9_;
         if(_loc10_ <= 0)
         {
            cp.Copy(param3);
         }
         else if(_loc10_ >= param5)
         {
            cp.Copy(param4);
         }
         else
         {
            cp.x = param3.x + _loc10_ * _loc8_;
            cp.y = param3.y + _loc10_ * _loc9_;
         }
         var _loc11_:Number = param1.x - cp.x;
         var _loc12_:Number = param1.y - cp.y;
         var _loc13_:Number = _loc11_ * _loc11_ + _loc12_ * _loc12_;
         if(_loc13_ < param2 * param2)
         {
            return true;
         }
         return false;
      }
      
      public static function Overlap_Circle_Vs_Circle(param1:vec2, param2:Number, param3:vec2, param4:Number) : Boolean
      {
         var _loc5_:Number = param3.x - param1.x;
         var _loc6_:Number = param3.y - param1.y;
         var _loc7_:Number = _loc5_ * _loc5_ + _loc6_ * _loc6_;
         var _loc8_:Number = param2 + param4;
         if(_loc7_ < _loc8_ * _loc8_)
         {
            return true;
         }
         return false;
      }
      
      public static function TimeOfIntersection_Circle_vs_Circle(param1:vec2, param2:vec2, param3:vec2, param4:vec2, param5:Number) : Number
      {
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc6_:Number = param2.x - param4.x;
         var _loc7_:Number = param2.y - param4.y;
         var _loc8_:Number = param1.x - param3.x;
         var _loc9_:Number = param1.y - param3.y;
         var _loc10_:Number = _loc6_ * _loc6_ + _loc7_ * _loc7_;
         var _loc11_:Number = 2 * (_loc8_ * _loc6_ + _loc9_ * _loc7_);
         var _loc12_:Number = _loc8_ * _loc8_ + _loc9_ * _loc9_ - param5 * param5;
         var _loc13_:Number = 0.0001;
         if(_loc12_ <= 0)
         {
            return -1;
         }
         if(Math.abs(_loc10_) < _loc13_)
         {
            return 2;
         }
         if(_loc11_ >= 0)
         {
            return 2;
         }
         _loc14_ = _loc11_ * _loc11_ - 4 * _loc10_ * _loc12_;
         if(_loc14_ < 0)
         {
            return 2;
         }
         _loc15_ = -0.5 * (_loc11_ - Math.sqrt(_loc14_));
         _loc16_ = _loc15_ / _loc10_;
         _loc17_ = _loc12_ / _loc15_;
         return Math.min(_loc16_,_loc17_);
      }
      
      public static function TimeOfIntersection_Point_vs_Lineseg(param1:vec2, param2:vec2, param3:vec2, param4:vec2, param5:Number) : Number
      {
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc6_:Number = param4.x - param3.x;
         var _loc7_:Number = param4.y - param3.y;
         var _loc8_:Number = Math.sqrt(_loc6_ * _loc6_ + _loc7_ * _loc7_);
         _loc6_ /= _loc8_;
         _loc7_ /= _loc8_;
         var _loc9_:Number = -_loc7_;
         var _loc10_:Number = _loc6_;
         var _loc11_:Number = param1.x - param3.x;
         var _loc12_:Number = param1.y - param3.y;
         var _loc13_:Number = _loc9_ * _loc11_ + _loc10_ * _loc12_;
         var _loc14_:Number = _loc9_ * param2.x + _loc10_ * param2.y;
         var _loc15_:Number = _loc6_ * _loc11_ + _loc7_ * _loc12_;
         var _loc16_:Number = Math.abs(_loc13_);
         var _loc17_:Number = _loc16_ - param5;
         if(_loc17_ < 0)
         {
            if(_loc15_ < 0 || _loc15_ > _loc8_)
            {
               return 2;
            }
            return -1;
         }
         if(_loc13_ * _loc14_ >= 0)
         {
            return 2;
         }
         _loc18_ = _loc17_ / Math.abs(_loc14_);
         _loc19_ = _loc6_ * param2.x + _loc7_ * param2.y;
         _loc20_ = _loc15_ + _loc18_ * _loc19_;
         if(_loc20_ < 0 || _loc20_ > _loc8_)
         {
            return 2;
         }
         return _loc18_;
      }
      
      public static function TimeOfIntersection_Circle_vs_Arc(param1:vec2, param2:vec2, param3:vec2, param4:vec2, param5:vec2, param6:Number) : Number
      {
         var _loc7_:Number = param4.x - param3.x;
         var _loc8_:Number = param4.y - param3.y;
         var _loc9_:Number = Math.sqrt(_loc7_ * _loc7_ + _loc8_ * _loc8_);
         var _loc10_:Number = TimeOfIntersection_Circle_vs_Arc_HELPER(param1,param2,param3,param4,param5,_loc9_ + param6);
         var _loc11_:Number = TimeOfIntersection_Circle_vs_Arc_HELPER(param1,param2,param3,param4,param5,_loc9_ - param6);
         return Math.min(_loc10_,_loc11_);
      }
      
      private static function TimeOfIntersection_Circle_vs_Arc_HELPER(param1:vec2, param2:vec2, param3:vec2, param4:vec2, param5:vec2, param6:Number) : Number
      {
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc24_:Number = NaN;
         var _loc25_:Number = NaN;
         var _loc26_:Number = NaN;
         var _loc27_:Number = NaN;
         var _loc28_:Number = NaN;
         var _loc29_:Number = NaN;
         var _loc30_:Number = NaN;
         var _loc31_:Number = NaN;
         var _loc32_:Number = NaN;
         var _loc7_:Number = param1.x - param3.x;
         var _loc8_:Number = param1.y - param3.y;
         var _loc9_:Number = param2.Dot(param2);
         var _loc10_:Number = 2 * (_loc7_ * param2.x + _loc8_ * param2.y);
         var _loc11_:Number = _loc7_ * _loc7_ + _loc8_ * _loc8_ - param6 * param6;
         var _loc12_:Number = 0.0001;
         if(Math.abs(_loc9_) < _loc12_)
         {
            return 2;
         }
         _loc13_ = _loc10_ * _loc10_ - 4 * _loc9_ * _loc11_;
         if(_loc13_ < 0)
         {
            return 2;
         }
         _loc14_ = -0.5 * (_loc10_ - Math.sqrt(_loc13_));
         _loc15_ = _loc14_ / _loc9_;
         _loc16_ = _loc11_ / _loc14_;
         _loc17_ = param4.x - param3.x;
         _loc18_ = param4.y - param3.y;
         _loc19_ = param5.x - param3.x;
         _loc20_ = param5.y - param3.y;
         _loc21_ = param5.x - param4.x;
         _loc22_ = param5.y - param4.y;
         _loc23_ = _loc21_ * -_loc18_ + _loc22_ * _loc17_;
         _loc24_ = _loc21_ * -_loc20_ + _loc22_ * _loc19_;
         if(_loc15_ < 0)
         {
            _loc15_ = 2;
         }
         if(_loc16_ < 0)
         {
            _loc16_ = 2;
         }
         if(_loc15_ <= 1)
         {
            _loc25_ = param1.x + _loc15_ * param2.x - param3.x;
            _loc26_ = param1.y + _loc15_ * param2.y - param3.y;
            _loc27_ = _loc25_ * -_loc18_ + _loc26_ * _loc17_;
            _loc28_ = _loc25_ * -_loc20_ + _loc26_ * _loc19_;
            if(_loc27_ * _loc23_ <= 0 || _loc28_ * _loc24_ >= 0)
            {
               _loc15_ = 2;
            }
         }
         if(_loc16_ <= 1)
         {
            _loc29_ = param1.x + _loc16_ * param2.x - param3.x;
            _loc30_ = param1.y + _loc16_ * param2.y - param3.y;
            _loc31_ = _loc29_ * -_loc18_ + _loc30_ * _loc17_;
            _loc32_ = _loc29_ * -_loc20_ + _loc30_ * _loc19_;
            if(_loc31_ * _loc23_ <= 0 || _loc32_ * _loc24_ >= 0)
            {
               _loc16_ = 2;
            }
         }
         return Math.min(_loc15_,_loc16_);
      }
   }
}

