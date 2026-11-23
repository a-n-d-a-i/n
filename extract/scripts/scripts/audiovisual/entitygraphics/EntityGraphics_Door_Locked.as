package audiovisual.entitygraphics
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import simulation.entities.Entity_Door_Locked;
   
   public class EntityGraphics_Door_Locked implements EntityGraphics
   {
      
      public static const ANIM_CLOSE:int = 0;
      
      public static const ANIM_OPEN:int = 1;
      
      private var mc_door:MovieClip;
      
      private var mc_switch:MovieClip;
      
      private var entity:Entity_Door_Locked;
      
      public var anim:int;
      
      public function EntityGraphics_Door_Locked(param1:Entity_Door_Locked, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number)
      {
         super();
         this.entity = param1;
         this.mc_door = new asset_gfx_door_locked();
         this.mc_switch = new asset_gfx_door_locked_switch();
         this.mc_door.x = param2;
         this.mc_door.y = param3;
         this.mc_door.rotation = param4 / Math.PI * 180;
         this.mc_door.gotoAndStop("closed");
         this.mc_switch.x = param5;
         this.mc_switch.y = param6;
         this.mc_switch.gotoAndStop("closed");
         this.mc_switch.cacheAsBitmap = true;
         this.anim = ANIM_CLOSE;
      }
      
      public function RegisterGraphics(param1:Vector.<DisplayObject>) : void
      {
         param1.push(this.mc_door);
         param1.unshift(this.mc_switch);
      }
      
      public function UpdateState() : void
      {
         var _loc1_:int = this.anim;
         this.entity.GFX_UpdateState(this);
         if(this.anim != _loc1_)
         {
            if(this.anim == ANIM_OPEN)
            {
               this.mc_door.gotoAndPlay("open");
               this.mc_switch.gotoAndPlay("open");
            }
         }
      }
   }
}

