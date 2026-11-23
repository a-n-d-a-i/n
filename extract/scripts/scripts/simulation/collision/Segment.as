package simulation.collision
{
   import math.vec2;
   import simpleFramework.SimpleRenderer;
   
   public interface Segment
   {
      
      function GetAABB() : AABB;
      
      function GetClosestPoint(param1:vec2, param2:vec2) : void;
      
      function IntersectWithRay(param1:vec2, param2:vec2, param3:Number, param4:vec2, param5:vec2) : Number;
      
      function GetClosestPoint_IsBackfacing(param1:vec2, param2:vec2) : Boolean;
      
      function DebugDraw(param1:SimpleRenderer) : void;
      
      function DebugDraw_NoStyle(param1:SimpleRenderer) : void;
      
      function DebugDraw_Simple(param1:SimpleRenderer) : void;
   }
}

