package simulation.entities
{
   import audiovisual.entitygraphics.EntityGraphics;
   import audiovisual.entitygraphics.EntityGraphics_Door_Locked;
   import math.vec2;
   import simpleFramework.SimpleRenderer;
   import simulation.Simulator;
   import simulation.collision.Grid_Edges;
   import simulation.collision.Grid_Entity;
   import simulation.collision.Grid_Segment;
   import simulation.collision.Segment;
   
   public class Entity_Door_Locked extends Entity_Door_Base
   {
      
      public function Entity_Door_Locked(param1:Grid_Entity, param2:Grid_Segment, param3:int, param4:Segment, param5:Grid_Edges, param6:Vector.<int>, param7:Boolean, param8:Number, param9:Number)
      {
         var _loc10_:Number = 12 * (5 / 12);
         super(param1,param2,param3,param4,param5,param6,param7,param8,param9,_loc10_,false);
      }
      
      override protected function OnCollision(param1:Simulator) : void
      {
         param1.objGrid.ENTITY_Remove(this);
         ChangeDoorState(true);
      }
      
      override public function GenerateGraphicComponent() : EntityGraphics
      {
         var _loc1_:vec2 = GetDoorPos();
         return new EntityGraphics_Door_Locked(this,_loc1_.x,_loc1_.y,GetDoorOrn(),trigger_pos.x,trigger_pos.y);
      }
      
      public function GFX_UpdateState(param1:EntityGraphics_Door_Locked) : void
      {
         if(IsDoorOpen())
         {
            param1.anim = EntityGraphics_Door_Locked.ANIM_OPEN;
         }
         else
         {
            param1.anim = EntityGraphics_Door_Locked.ANIM_CLOSE;
         }
      }
      
      override public function Debug_Draw(param1:SimpleRenderer) : void
      {
         Debug_Draw_Base(param1,!IsDoorOpen());
         param1.SetStyle(4,2237064,10);
         seg.DebugDraw_NoStyle(param1);
      }
   }
}

