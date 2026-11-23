package audiovisual.entitygraphics
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import simulation.entities.Entity_Mine;
   
   public class EntityGraphics_Mine implements EntityGraphics
   {
      
      public static const ANIM_UNEXPLODED:int = 0;
      
      public static const ANIM_EXPLODED:int = 1;
      
      private var mc:MovieClip;
      
      private var entity:Entity_Mine;
      
      public var anim:int;
      
      public function EntityGraphics_Mine(param1:Entity_Mine, param2:Number, param3:Number)
      {
         super();
         this.entity = param1;
         this.mc = new asset_gfx_mine();
         this.mc.x = param2;
         this.mc.y = param3;
         this.mc.gotoAndStop("unexploded");
         this.mc.cacheAsBitmap = true;
         this.anim = ANIM_UNEXPLODED;
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
            if(this.anim == ANIM_EXPLODED)
            {
               this.mc.cacheAsBitmap = false;
               this.mc.gotoAndPlay("exploded");
            }
         }
      }
   }
}

