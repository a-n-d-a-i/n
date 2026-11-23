package audiovisual.entitygraphics
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import math.vec2;
   import simulation.entities.Entity_Drone_Chaingun;
   
   public class EntityGraphics_Drone_Chaingun implements EntityGraphics
   {
      
      public static const ANIM_MOVE:int = 0;
      
      public static const ANIM_PREFIRE:int = 1;
      
      public static const ANIM_FIRING:int = 2;
      
      public static const ANIM_POSTFIRE:int = 3;
      
      private var mc_body:MovieClip;
      
      private var mc_eye:MovieClip;
      
      private var entity:Entity_Drone_Chaingun;
      
      public var pos:vec2;
      
      public var orn:Number;
      
      public var anim:int;
      
      public function EntityGraphics_Drone_Chaingun(param1:Entity_Drone_Chaingun)
      {
         super();
         this.entity = param1;
         this.mc_body = new asset_gfx_drone_chaingun();
         this.mc_eye = new asset_gfx_drone_chaingun_eye();
         this.mc_body.addChild(this.mc_eye);
         this.pos = new vec2();
         this.orn = 0;
         this.anim = ANIM_MOVE;
         this.mc_body.gotoAndStop("move");
      }
      
      public function RegisterGraphics(param1:Vector.<DisplayObject>) : void
      {
         param1.push(this.mc_body);
      }
      
      public function UpdateState() : void
      {
         var _loc1_:int = this.anim;
         this.entity.GFX_UpdateState(this);
         this.mc_body.x = this.pos.x;
         this.mc_body.y = this.pos.y;
         this.mc_eye.rotation = this.orn / Math.PI * 180;
         if(this.anim != _loc1_)
         {
            if(this.anim == ANIM_MOVE)
            {
               this.mc_body.gotoAndStop("move");
            }
            else if(this.anim == ANIM_PREFIRE)
            {
               this.mc_body.gotoAndPlay("prefire");
            }
            else if(this.anim == ANIM_POSTFIRE)
            {
               this.mc_body.gotoAndPlay("postfire");
            }
            else if(this.anim == ANIM_FIRING)
            {
               this.mc_body.gotoAndStop("fire");
            }
         }
      }
   }
}

