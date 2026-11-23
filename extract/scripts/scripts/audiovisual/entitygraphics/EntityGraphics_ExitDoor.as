package audiovisual.entitygraphics
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import simulation.entities.Entity_ExitDoor;
   
   public class EntityGraphics_ExitDoor implements EntityGraphics
   {
      
      public static const ANIM_CLOSED:int = 0;
      
      public static const ANIM_OPEN:int = 1;
      
      private var mc:MovieClip;
      
      private var entity:Entity_ExitDoor;
      
      public var anim:int;
      
      public function EntityGraphics_ExitDoor(param1:Entity_ExitDoor, param2:Number, param3:Number)
      {
         super();
         this.entity = param1;
         this.mc = new asset_gfx_exitdoor();
         this.mc.x = param2;
         this.mc.y = param3;
         this.mc.gotoAndStop("closed");
         this.anim = ANIM_CLOSED;
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
            if(this.anim == ANIM_OPEN)
            {
               this.mc.gotoAndPlay("open");
            }
         }
      }
   }
}

