package audiovisual.entitygraphics
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import math.vec2;
   import simulation.entities.Entity_BounceBlock;
   
   public class EntityGraphics_BounceBlock implements EntityGraphics
   {
      
      private var mc:MovieClip;
      
      private var entity:Entity_BounceBlock;
      
      public var pos:vec2;
      
      public function EntityGraphics_BounceBlock(param1:Entity_BounceBlock)
      {
         super();
         this.entity = param1;
         this.mc = new asset_gfx_bounceblock();
         this.mc.cacheAsBitmap = true;
         this.pos = new vec2();
      }
      
      public function RegisterGraphics(param1:Vector.<DisplayObject>) : void
      {
         param1.push(this.mc);
      }
      
      public function UpdateState() : void
      {
         this.entity.GFX_UpdateState(this);
         this.mc.x = this.pos.x;
         this.mc.y = this.pos.y;
      }
   }
}

