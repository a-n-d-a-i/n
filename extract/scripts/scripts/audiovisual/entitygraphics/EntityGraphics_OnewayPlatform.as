package audiovisual.entitygraphics
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class EntityGraphics_OnewayPlatform implements EntityGraphics
   {
      
      private var mc:MovieClip;
      
      public function EntityGraphics_OnewayPlatform(param1:Number, param2:Number, param3:Number)
      {
         super();
         this.mc = new asset_gfx_oneway();
         this.mc.x = param1;
         this.mc.y = param2;
         this.mc.rotation = param3 / Math.PI * 180;
         this.mc.cacheAsBitmap = true;
      }
      
      public function RegisterGraphics(param1:Vector.<DisplayObject>) : void
      {
         param1.unshift(this.mc);
      }
      
      public function UpdateState() : void
      {
      }
   }
}

