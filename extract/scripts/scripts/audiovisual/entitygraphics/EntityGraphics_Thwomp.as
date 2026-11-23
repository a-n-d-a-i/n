package audiovisual.entitygraphics
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import math.vec2;
   import simulation.entities.Entity_Thwomp;
   
   public class EntityGraphics_Thwomp implements EntityGraphics
   {
      
      private var mc:MovieClip;
      
      private var entity:Entity_Thwomp;
      
      public var pos:vec2;
      
      public function EntityGraphics_Thwomp(param1:Entity_Thwomp, param2:Number)
      {
         super();
         this.entity = param1;
         this.mc = new asset_gfx_thwomp();
         this.mc.rotation = param2 / Math.PI * 180;
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

