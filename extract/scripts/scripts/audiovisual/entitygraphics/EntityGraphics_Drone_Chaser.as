package audiovisual.entitygraphics
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import math.vec2;
   import simulation.entities.Entity_Drone_Chaser;
   
   public class EntityGraphics_Drone_Chaser implements EntityGraphics
   {
      
      public static const ANIM_IDLE:int = 0;
      
      public static const ANIM_CHASE:int = 1;
      
      private var mc_body:MovieClip;
      
      private var mc_eye:MovieClip;
      
      private var entity:Entity_Drone_Chaser;
      
      public var pos:vec2;
      
      public var orn:Number;
      
      public var anim:int;
      
      public function EntityGraphics_Drone_Chaser(param1:Entity_Drone_Chaser)
      {
         super();
         this.entity = param1;
         this.mc_body = new asset_gfx_drone_chaser();
         this.mc_eye = new asset_gfx_drone_eye();
         this.mc_body.cacheAsBitmap = true;
         this.pos = new vec2();
         this.orn = 0;
         this.anim = ANIM_IDLE;
         this.mc_body.gotoAndStop("idle");
      }
      
      public function RegisterGraphics(param1:Vector.<DisplayObject>) : void
      {
         param1.push(this.mc_body);
         param1.push(this.mc_eye);
      }
      
      public function UpdateState() : void
      {
         var _loc1_:int = this.anim;
         this.entity.GFX_UpdateState(this);
         this.mc_body.x = this.pos.x;
         this.mc_body.y = this.pos.y;
         this.mc_eye.x = this.pos.x;
         this.mc_eye.y = this.pos.y;
         this.mc_eye.rotation = this.orn / Math.PI * 180;
         if(this.anim == ANIM_CHASE)
         {
            this.mc_body.gotoAndPlay("chase");
            this.anim = ANIM_IDLE;
         }
         else if(this.anim == ANIM_IDLE)
         {
            this.mc_body.gotoAndStop("idle");
         }
      }
   }
}

