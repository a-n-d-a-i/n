package com.metanet.ui
{
   public class TimeFormatter
   {
      
      public function TimeFormatter()
      {
         super();
      }
      
      public function formatTime(param1:int, param2:int) : String
      {
         var _loc6_:* = null;
         var _loc3_:Number = param1 / param2;
         var _loc4_:Array = _loc3_.toString().split(".");
         var _loc5_:String = _loc4_[0];
         if(_loc4_.length == 1)
         {
            _loc6_ = "000";
         }
         else
         {
            _loc6_ = _loc4_[1].substr(0,3);
         }
         while(_loc5_.length < 4)
         {
            _loc5_ = " " + _loc5_;
         }
         while(_loc6_.length < 3)
         {
            _loc6_ += "0";
         }
         return _loc5_ + _loc6_;
      }
   }
}

