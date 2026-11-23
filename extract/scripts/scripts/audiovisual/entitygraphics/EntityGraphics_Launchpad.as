package audiovisual.entitygraphics
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import simulation.entities.Entity_Launchpad;
   
   public class EntityGraphics_Launchpad implements EntityGraphics
   {
      
      public static const ANIM_IDLE:int = 0;
      
      public static const ANIM_LAUNCH:int = 1;
      
      private var mc:MovieClip;
      
      private var entity:Entity_Launchpad;
      
      public var anim:int;
      
      public function EntityGraphics_Launchpad(param1:Entity_Launchpad, param2:Number, param3:Number, param4:Number)
      {
         super();
         this.entity = param1;
         this.mc = new asset_gfx_launchpad();
         this.mc.x = param2;
         this.mc.y = param3;
         this.mc.rotation = param4 / Math.PI * 180;
         this.mc.gotoAndStop("idle");
         this.mc.cacheAsBitmap = true;
         this.anim = ANIM_IDLE;
      }
      
      public function RegisterGraphics(param1:Vector.<DisplayObject>) : void
      {
         param1.unshift(this.mc);
      }
      
      public function UpdateState() : void
      {
         var _loc1_:int = this.anim;
         this.entity.GFX_UpdateState(this);
         if(this.anim != _loc1_)
         {
            if(this.anim == ANIM_LAUNCH)
            {
               this.mc.gotoAndPlay("launch");
            }
         }
      }
   }
}

