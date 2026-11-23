package simulation.entities
{
   import audiovisual.entitygraphics.EntityGraphics;
   import math.vec2;
   import simpleFramework.SimpleRenderer;
   import simulation.Simulator;
   import simulation.ninja.Ninja;
   
   public class Entity_Base
   {
      
      private var UID:int;
      
      private var grid_index:int;
      
      public function Entity_Base()
      {
         super();
         this.UID = -1;
         this.grid_index = -1;
      }
      
      final public function GAME_SetUID(param1:uint) : void
      {
         this.UID = param1;
      }
      
      final public function GetUID() : uint
      {
         return this.UID;
      }
      
      final public function GRID_GetGridIndex() : int
      {
         return this.grid_index;
      }
      
      final public function GRID_SetGridIndex(param1:int) : void
      {
         this.grid_index = param1;
      }
      
      public function CollideVsCircle_Physical(param1:collision_result_physical, param2:vec2, param3:vec2, param4:vec2, param5:Number) : Boolean
      {
         return false;
      }
      
      public function CollideVsCircle_Logical(param1:Simulator, param2:Ninja, param3:collision_result_logical, param4:vec2, param5:vec2, param6:vec2, param7:Number, param8:Number) : Boolean
      {
         return false;
      }
      
      public function Think(param1:Simulator) : void
      {
      }
      
      public function Move(param1:Simulator) : void
      {
      }
      
      public function GenerateGraphicComponent() : EntityGraphics
      {
         return null;
      }
      
      public function Debug_Draw(param1:SimpleRenderer) : void
      {
      }
   }
}

