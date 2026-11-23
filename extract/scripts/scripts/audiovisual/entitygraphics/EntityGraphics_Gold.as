package audiovisual.entitygraphics
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import simulation.entities.Entity_Gold;
   
   public class EntityGraphics_Gold implements EntityGraphics
   {
      
      public static const ANIM_NOT_COLLECTED:int = 0;
      
      public static const ANIM_COLLECTED:int = 1;
      
      private var mc:MovieClip;
      
      private var entity:Entity_Gold;
      
      public var anim:int;
      
      public function EntityGraphics_Gold(param1:Entity_Gold, param2:Number, param3:Number)
      {
         super();
         this.entity = param1;
         this.mc = new asset_gfx_gold();
         this.mc.x = param2;
         this.mc.y = param3;
         this.mc.gotoAndStop("not_collected");
         this.mc.cacheAsBitmap = true;
         this.anim = ANIM_NOT_COLLECTED;
      }
      
      public function RegisterGraphics(param1:Vector.<DisplayObject>) : void
      {
         param1.push(this.mc);
      }
      
      public function UpdateState() : void
      {
         var _loc1_:int = this.anim;
         this.entity.GFX_UpdateState(this);
         if(this.anim != _loc1_)
         {
            if(this.anim == ANIM_COLLECTED)
            {
               this.mc.cacheAsBitmap = false;
               this.mc.gotoAndPlay("collected");
            }
         }
      }
   }
}

