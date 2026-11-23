package audiovisual.entitygraphics
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import math.vec2;
   import simulation.entities.Entity_FloorGuard;
   
   public class EntityGraphics_FloorGuard implements EntityGraphics
   {
      
      public static const ANIM_IDLE:int = 0;
      
      public static const ANIM_CHASE_L:int = -1;
      
      public static const ANIM_CHASE_R:int = 1;
      
      private var mc:MovieClip;
      
      private var entity:Entity_FloorGuard;
      
      public var pos:vec2;
      
      public var anim:int;
      
      public function EntityGraphics_FloorGuard(param1:Entity_FloorGuard)
      {
         super();
         this.entity = param1;
         this.mc = new asset_gfx_floorguard();
         this.mc.cacheAsBitmap = true;
         this.pos = new vec2();
         this.anim = ANIM_IDLE;
      }
      
      public function RegisterGraphics(param1:Vector.<DisplayObject>) : void
      {
         param1.push(this.mc);
      }
      
      public function UpdateState() : void
      {
         var _loc1_:int = this.anim;
         this.entity.GFX_UpdateState(this);
         this.mc.x = this.pos.x;
         this.mc.y = this.pos.y;
         if(this.anim != _loc1_)
         {
            if(this.anim == ANIM_CHASE_L || this.anim == ANIM_CHASE_R)
            {
               this.mc.gotoAndPlay("chase");
            }
            else if(this.anim == ANIM_IDLE)
            {
               this.mc.gotoAndStop("idle");
            }
         }
      }
   }
}

