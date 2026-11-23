package simulation.entities
{
   import audiovisual.entitygraphics.EntityGraphics;
   import audiovisual.entitygraphics.EntityGraphics_ExitDoor;
   import math.vec2;
   import simpleFramework.SimpleRenderer;
   import simulation.Simulator;
   import simulation.collision.Grid_Entity;
   import simulation.collision.colutils;
   import simulation.ninja.Ninja;
   
   public class Entity_ExitDoor extends Entity_Base
   {
      
      private var pos:vec2;
      
      private var r:Number;
      
      private var isOpen:Boolean;
      
      public function Entity_ExitDoor(param1:Number, param2:Number)
      {
         super();
         this.pos = new vec2(param1,param2);
         this.r = 12;
         this.isOpen = false;
      }
      
      override public function CollideVsCircle_Logical(param1:Simulator, param2:Ninja, param3:collision_result_logical, param4:vec2, param5:vec2, param6:vec2, param7:Number, param8:Number) : Boolean
      {
         if(param2 != null)
         {
            if(colutils.Overlap_Circle_Vs_Circle(this.pos,this.r,param4,param7))
            {
               param1.Event_Exit_HitPlayer(param2);
            }
         }
         return false;
      }
      
      public function SWITCH_OpenTheExit(param1:Grid_Entity) : void
      {
         this.isOpen = true;
         param1.ENTITY_Add(this.pos,this);
      }
      
      public function SWITCH_IsOpen() : Boolean
      {
         return this.isOpen;
      }
      
      override public function GenerateGraphicComponent() : EntityGraphics
      {
         return new EntityGraphics_ExitDoor(this,this.pos.x,this.pos.y);
      }
      
      public function GFX_UpdateState(param1:EntityGraphics_ExitDoor) : void
      {
         if(this.isOpen)
         {
            param1.anim = EntityGraphics_ExitDoor.ANIM_OPEN;
         }
         else
         {
            param1.anim = EntityGraphics_ExitDoor.ANIM_CLOSED;
         }
      }
      
      override public function Debug_Draw(param1:SimpleRenderer) : void
      {
         if(this.isOpen)
         {
            param1.SetStyle(0,0,100);
            param1.DrawSquare(this.pos.x,this.pos.y,this.r);
            param1.DrawSquare(this.pos.x,this.pos.y,this.r - 2);
         }
         else
         {
            param1.SetStyle(0,0,30);
            param1.DrawCross(this.pos.x,this.pos.y,this.r);
            param1.DrawSquare(this.pos.x,this.pos.y,this.r);
         }
      }
   }
}

