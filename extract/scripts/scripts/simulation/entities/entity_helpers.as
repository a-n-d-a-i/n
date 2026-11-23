package simulation.entities
{
   import math.vec2;
   import simulation.collision.Grid_Segment;
   import simulation.ninja.Ninja;
   
   public class entity_helpers
   {
      
      public static const zero_vec:vec2 = new vec2(0,0);
      
      public static var potentialList:Vector.<int> = new Vector.<int>();
      
      public function entity_helpers()
      {
         super();
      }
      
      public static function TryToAquireTarget(param1:vec2, param2:Vector.<Ninja>, param3:Grid_Segment) : int
      {
         var _loc5_:uint = 0;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:int = 0;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         potentialList.length = 0;
         var _loc4_:int = 0;
         while(_loc4_ < param2.length)
         {
            if(!param2[_loc4_].IsDead())
            {
               if(param3.RaycastVsPlayer(param1,param2[_loc4_].GetPos(),param2[_loc4_].GetRadius(),zero_vec,zero_vec))
               {
                  potentialList.push(_loc4_);
               }
            }
            _loc4_++;
         }
         if(potentialList.length > 0)
         {
            _loc5_ = 0;
            _loc6_ = param2[potentialList[0]].GetPos().x - param1.x;
            _loc7_ = param2[potentialList[0]].GetPos().y - param1.y;
            _loc8_ = _loc6_ * _loc6_ + _loc7_ * _loc7_;
            _loc9_ = 1;
            while(_loc9_ < potentialList.length)
            {
               _loc10_ = param2[potentialList[_loc9_]].GetPos().x - param1.x;
               _loc11_ = param2[potentialList[_loc9_]].GetPos().y - param1.y;
               _loc12_ = _loc10_ * _loc10_ + _loc11_ * _loc11_;
               if(_loc12_ < _loc8_)
               {
                  _loc5_ = uint(_loc9_);
               }
               _loc9_++;
            }
            return potentialList[_loc5_];
         }
         return -1;
      }
   }
}

