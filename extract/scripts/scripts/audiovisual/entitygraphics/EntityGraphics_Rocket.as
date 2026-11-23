package audiovisual.entitygraphics
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import math.vec2;
   import simulation.entities.Entity_Rocket;
   
   public class EntityGraphics_Rocket implements EntityGraphics
   {
      
      public static const ANIM_IDLE:int = 0;
      
      public static const ANIM_FIRE:int = 1;
      
      public static const ANIM_EXPLODE:int = 2;
      
      private var mc_base:MovieClip;
      
      private var mc_rocket:MovieClip;
      
      private var entity:Entity_Rocket;
      
      public var anim_base:int;
      
      public var pos_rocket:vec2;
      
      public var orn_rocket:Number;
      
      public var is_rocket_active:Boolean;
      
      public function EntityGraphics_Rocket(param1:Entity_Rocket, param2:Number, param3:Number)
      {
         super();
         this.entity = param1;
         this.mc_base = new asset_gfx_rocket_base();
         this.mc_base.x = param2;
         this.mc_base.y = param3;
         this.mc_base.gotoAndStop("idle");
         this.anim_base = ANIM_IDLE;
         this.mc_base.cacheAsBitmap = true;
         this.mc_rocket = new asset_gfx_rocket();
         this.mc_rocket.visible = false;
         this.pos_rocket = new vec2();
         this.orn_rocket = 0;
         this.is_rocket_active = false;
      }
      
      public function RegisterGraphics(param1:Vector.<DisplayObject>) : void
      {
         param1.unshift(this.mc_base);
         param1.push(this.mc_rocket);
      }
      
      public function UpdateState() : void
      {
         var _loc1_:int = this.anim_base;
         this.entity.GFX_UpdateState(this);
         if(this.anim_base != _loc1_)
         {
            if(this.anim_base == ANIM_IDLE)
            {
               this.mc_base.gotoAndStop("idle");
            }
            else if(this.anim_base == ANIM_FIRE)
            {
               this.mc_base.gotoAndPlay("fire");
            }
            else if(this.anim_base == ANIM_EXPLODE)
            {
               this.mc_base.gotoAndPlay("explode");
            }
         }
         if(this.is_rocket_active)
         {
            this.mc_rocket.visible = true;
            this.mc_rocket.x = this.pos_rocket.x;
            this.mc_rocket.y = this.pos_rocket.y;
            this.mc_rocket.rotation = this.orn_rocket / Math.PI * 180;
         }
         else
         {
            this.mc_rocket.visible = false;
         }
      }
   }
}

