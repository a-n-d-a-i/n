package simulation.entities
{
   import audiovisual.entitygraphics.EntityGraphics;
   import audiovisual.entitygraphics.EntityGraphics_Launchpad;
   import math.vec2;
   import simpleFramework.SimpleRenderer;
   import simulation.Simulator;
   import simulation.collision.Grid_Entity;
   import simulation.collision.colutils;
   import simulation.ninja.Ninja;
   
   public class Entity_Launchpad extends Entity_Base
   {
      
      private var pos:vec2;
      
      private var n:vec2;
      
      private var r:Number;
      
      private var strength:Number;
      
      private var pow:Number;
      
      private var gfx_triggerEvent:Boolean;
      
      public function Entity_Launchpad(param1:Grid_Entity, param2:Number, param3:Number, param4:Number, param5:Number)
      {
         super();
         this.pos = new vec2(param2,param3);
         this.n = new vec2(param4,param5);
         this.r = 12 * 0.5;
         this.strength = 12 * (3 / 7);
         param1.ENTITY_Add(this.pos,this);
         this.gfx_triggerEvent = false;
      }
      
      override public function CollideVsCircle_Logical(param1:Simulator, param2:Ninja, param3:collision_result_logical, param4:vec2, param5:vec2, param6:vec2, param7:Number, param8:Number) : Boolean
      {
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         if(colutils.Overlap_Circle_Vs_Circle(this.pos,this.r,param4,param7))
         {
            _loc9_ = this.pos.x - (param4.x - this.n.x * param7);
            _loc10_ = this.pos.y - (param4.y - this.n.y * param7);
            param8 = 0.1;
            if(-param8 <= this.n.x * _loc9_ + this.n.y * _loc10_)
            {
               _loc11_ = 1;
               if(this.n.y < 0)
               {
                  _loc11_ += Math.abs(this.n.y);
               }
               if(param2 == null)
               {
                  param3.vec_x = this.n.x * 12;
                  param3.vec_y = this.n.y * 12;
                  this.gfx_triggerEvent = true;
                  return true;
               }
               param1.Event_Launchpad_HitPlayer(param2,this.n.x * this.strength,this.n.y * this.strength * _loc11_);
               this.gfx_triggerEvent = true;
            }
         }
         return false;
      }
      
      override public function GenerateGraphicComponent() : EntityGraphics
      {
         return new EntityGraphics_Launchpad(this,this.pos.x,this.pos.y,Math.atan2(this.n.y,this.n.x));
      }
      
      public function GFX_UpdateState(param1:EntityGraphics_Launchpad) : void
      {
         if(this.gfx_triggerEvent)
         {
            param1.anim = EntityGraphics_Launchpad.ANIM_LAUNCH;
            this.gfx_triggerEvent = false;
         }
         else
         {
            param1.anim = EntityGraphics_Launchpad.ANIM_IDLE;
         }
      }
      
      override public function Debug_Draw(param1:SimpleRenderer) : void
      {
         param1.SetStyle(0,0,100);
         param1.DrawBox(this.pos.x,this.pos.y,-this.n.y * this.r,this.n.x * this.r,this.n.x * 2,this.n.y * 2);
         param1.DrawLine(this.pos.x,this.pos.y,this.pos.x + this.n.x * 6,this.pos.y + this.n.y * 6);
      }
   }
}

