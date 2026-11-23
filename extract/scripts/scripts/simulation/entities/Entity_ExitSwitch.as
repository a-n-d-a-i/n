package simulation.entities
{
   import audiovisual.entitygraphics.EntityGraphics;
   import audiovisual.entitygraphics.EntityGraphics_ExitSwitch;
   import math.vec2;
   import simpleFramework.SimpleRenderer;
   import simulation.Simulator;
   import simulation.collision.Grid_Entity;
   import simulation.collision.colutils;
   import simulation.ninja.Ninja;
   
   public class Entity_ExitSwitch extends Entity_Base
   {
      
      private var pos:vec2;
      
      private var r:Number;
      
      private var door:Entity_ExitDoor;
      
      public function Entity_ExitSwitch(param1:Grid_Entity, param2:Number, param3:Number, param4:Entity_ExitDoor)
      {
         super();
         this.pos = new vec2(param2,param3);
         this.r = 12 * 0.5;
         this.door = param4;
         param1.ENTITY_Add(this.pos,this);
      }
      
      override public function CollideVsCircle_Logical(param1:Simulator, param2:Ninja, param3:collision_result_logical, param4:vec2, param5:vec2, param6:vec2, param7:Number, param8:Number) : Boolean
      {
         if(param2 != null)
         {
            if(colutils.Overlap_Circle_Vs_Circle(this.pos,this.r,param4,param7))
            {
               this.door.SWITCH_OpenTheExit(param1.objGrid);
               param1.objGrid.ENTITY_Remove(this);
            }
         }
         return false;
      }
      
      override public function GenerateGraphicComponent() : EntityGraphics
      {
         return new EntityGraphics_ExitSwitch(this,this.pos.x,this.pos.y);
      }
      
      public function GFX_UpdateState(param1:EntityGraphics_ExitSwitch) : void
      {
         if(this.door.SWITCH_IsOpen())
         {
            param1.anim = EntityGraphics_ExitSwitch.ANIM_OPEN;
         }
         else
         {
            param1.anim = EntityGraphics_ExitSwitch.ANIM_CLOSED;
         }
      }
      
      override public function Debug_Draw(param1:SimpleRenderer) : void
      {
         if(this.door.SWITCH_IsOpen())
         {
            param1.SetStyle(0,0,10);
         }
         else
         {
            param1.SetStyle(0,0,100);
         }
         param1.DrawSquare(this.pos.x,this.pos.y,this.r);
         param1.DrawCross(this.pos.x,this.pos.y,this.r);
      }
   }
}

