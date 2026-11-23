package audiovisual.entitygraphics
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import math.vec2;
   import simulation.entities.Entity_Turret;
   
   public class EntityGraphics_Turret implements EntityGraphics
   {
      
      public static const ANIM_IDLE:int = 0;
      
      public static const ANIM_PREFIRE:int = 1;
      
      public static const ANIM_FIRING:int = 2;
      
      public static const ANIM_POSTFIRE:int = 3;
      
      public static const CROSSHAIR_OFF:int = 0;
      
      public static const CROSSHAIR_FAR:int = 1;
      
      public static const CROSSHAIR_MID:int = 2;
      
      public static const CROSSHAIR_NEAR:int = 3;
      
      public static const CROSSHAIR_PREFIRE:int = 4;
      
      public static const CROSSHAIR_POSTFIRE:int = 5;
      
      private var mc_base:MovieClip;
      
      private var mc_crosshair:MovieClip;
      
      private var entity:Entity_Turret;
      
      public var anim_base:int;
      
      public var pos_crosshair:vec2;
      
      public var anim_crosshair:int;
      
      public function EntityGraphics_Turret(param1:Entity_Turret, param2:Number, param3:Number)
      {
         super();
         this.entity = param1;
         this.mc_base = new asset_gfx_turret();
         this.mc_base.x = param2;
         this.mc_base.y = param3;
         this.mc_base.gotoAndStop("idle");
         this.anim_base = ANIM_IDLE;
         this.mc_base.cacheAsBitmap = true;
         this.mc_crosshair = new asset_gfx_turret_crosshair();
         this.mc_crosshair.gotoAndStop("aim_off");
         this.anim_crosshair = CROSSHAIR_OFF;
         this.pos_crosshair = new vec2();
      }
      
      public function RegisterGraphics(param1:Vector.<DisplayObject>) : void
      {
         param1.unshift(this.mc_base);
         param1.push(this.mc_crosshair);
      }
      
      public function UpdateState() : void
      {
         var _loc1_:int = this.anim_base;
         var _loc2_:int = this.anim_crosshair;
         this.entity.GFX_UpdateState(this);
         if(this.anim_base != _loc1_)
         {
            if(this.anim_base == ANIM_IDLE)
            {
               this.mc_base.gotoAndStop("idle");
            }
            else if(this.anim_base == ANIM_PREFIRE)
            {
               this.mc_base.gotoAndPlay("prefire");
            }
            else if(this.anim_base == ANIM_POSTFIRE)
            {
               this.mc_base.gotoAndPlay("postfire");
            }
            else if(this.anim_base == ANIM_FIRING)
            {
               this.mc_base.gotoAndPlay("firing");
            }
         }
         this.mc_crosshair.x = this.pos_crosshair.x;
         this.mc_crosshair.y = this.pos_crosshair.y;
         if(this.anim_crosshair != _loc2_)
         {
            if(this.anim_crosshair == CROSSHAIR_OFF)
            {
               this.mc_crosshair.gotoAndStop("aim_off");
            }
            else if(this.anim_crosshair == CROSSHAIR_FAR)
            {
               this.mc_crosshair.gotoAndStop("aim_far");
            }
            else if(this.anim_crosshair == CROSSHAIR_MID)
            {
               this.mc_crosshair.gotoAndStop("aim_mid");
            }
            else if(this.anim_crosshair == CROSSHAIR_NEAR)
            {
               this.mc_crosshair.gotoAndStop("aim_near");
            }
            else if(this.anim_crosshair == CROSSHAIR_PREFIRE)
            {
               this.mc_crosshair.gotoAndStop("prefire");
            }
            else if(this.anim_crosshair == CROSSHAIR_POSTFIRE)
            {
               this.mc_crosshair.gotoAndStop("postfire");
            }
         }
      }
   }
}

