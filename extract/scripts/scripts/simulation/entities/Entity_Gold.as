package simulation.entities
{
   import audiovisual.entitygraphics.EntityGraphics;
   import audiovisual.entitygraphics.EntityGraphics_Gold;
   import math.vec2;
   import simpleFramework.SimpleRenderer;
   import simulation.Simulator;
   import simulation.collision.Grid_Entity;
   import simulation.collision.colutils;
   import simulation.ninja.Ninja;
   
   public class Entity_Gold extends Entity_Base
   {
      
      private var pos:vec2;
      
      private var r:Number;
      
      private var isCollected:Boolean;
      
      public function Entity_Gold(param1:Grid_Entity, param2:Number, param3:Number)
      {
         super();
         this.pos = new vec2(param2,param3);
         this.r = 12 * 0.5;
         this.isCollected = false;
         param1.ENTITY_Add(this.pos,this);
      }
      
      override public function CollideVsCircle_Logical(param1:Simulator, param2:Ninja, param3:collision_result_logical, param4:vec2, param5:vec2, param6:vec2, param7:Number, param8:Number) : Boolean
      {
         if(param2 != null)
         {
            if(colutils.Overlap_Circle_Vs_Circle(this.pos,this.r,param4,param7))
            {
               if(param1.Event_Gold_HitPlayer(param2))
               {
                  this.isCollected = true;
                  param1.objGrid.ENTITY_Remove(this);
                  param1.HACKY_GetSoundManager().PlaySound_Gold();
               }
            }
         }
         return false;
      }
      
      override public function GenerateGraphicComponent() : EntityGraphics
      {
         return new EntityGraphics_Gold(this,this.pos.x,this.pos.y);
      }
      
      public function GFX_UpdateState(param1:EntityGraphics_Gold) : void
      {
         if(this.isCollected)
         {
            param1.anim = EntityGraphics_Gold.ANIM_COLLECTED;
         }
         else
         {
            param1.anim = EntityGraphics_Gold.ANIM_NOT_COLLECTED;
         }
      }
      
      override public function Debug_Draw(param1:SimpleRenderer) : void
      {
         if(this.isCollected)
         {
            param1.SetStyle(0,0,10);
         }
         else
         {
            param1.SetStyle(0,0,100);
         }
         param1.DrawSquare(this.pos.x,this.pos.y,this.r / 2);
         param1.DrawCircle(this.pos.x,this.pos.y,this.r);
      }
   }
}

