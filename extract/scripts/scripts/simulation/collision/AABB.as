package simulation.collision
{
   import math.vec2;
   
   public class AABB
   {
      
      public var min:vec2;
      
      public var max:vec2;
      
      public function AABB(param1:Number, param2:Number, param3:Number, param4:Number)
      {
         super();
         this.min = new vec2(param1,param2);
         this.max = new vec2(param3,param4);
      }
   }
}

