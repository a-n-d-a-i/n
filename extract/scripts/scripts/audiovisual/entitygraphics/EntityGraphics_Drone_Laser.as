package audiovisual.entitygraphics
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import math.vec2;
   import simulation.entities.Entity_Drone_Laser;
   
   public class EntityGraphics_Drone_Laser implements EntityGraphics
   {
      
      public static const ANIM_MOVE:int = 0;
      
      public static const ANIM_PREFIRE:int = 1;
      
      public static const ANIM_FIRING:int = 2;
      
      public static const ANIM_POSTFIRE:int = 3;
      
      private var mc_body:MovieClip;
      
      private var mc_eye:MovieClip;
      
      private var mc_blast:MovieClip;
      
      private var mc_beam:Sprite;
      
      private var entity:Entity_Drone_Laser;
      
      public var pos:vec2;
      
      public var orn:Number;
      
      public var anim:int;
      
      public var blast_pos:vec2;
      
      public var blast_scale:Number;
      
      public function EntityGraphics_Drone_Laser(param1:Entity_Drone_Laser)
      {
         super();
         this.entity = param1;
         this.mc_body = new asset_gfx_drone_laser();
         this.mc_eye = new asset_gfx_drone_eye();
         this.mc_blast = new asset_gfx_laser_blast();
         this.mc_beam = new Sprite();
         this.pos = new vec2();
         this.orn = 0;
         this.anim = ANIM_MOVE;
         this.mc_body.gotoAndStop("move");
         this.blast_pos = new vec2();
         this.blast_scale = 0;
      }
      
      public function RegisterGraphics(param1:Vector.<DisplayObject>) : void
      {
         param1.push(this.mc_beam);
         param1.push(this.mc_body);
         param1.push(this.mc_eye);
         param1.push(this.mc_blast);
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
         if(this.anim != _loc1_)
         {
            if(this.anim == ANIM_MOVE)
            {
               this.mc_body.gotoAndStop("move");
            }
            else if(this.anim == ANIM_PREFIRE)
            {
               this.mc_body.gotoAndPlay("prefire");
               this.mc_beam.visible = true;
               this.mc_beam.graphics.clear();
               this.mc_beam.graphics.lineStyle(0,13334137);
               this.mc_beam.graphics.moveTo(this.pos.x,this.pos.y);
               this.mc_beam.graphics.lineTo(this.blast_pos.x,this.blast_pos.y);
            }
            else if(this.anim == ANIM_POSTFIRE)
            {
               this.mc_body.gotoAndPlay("postfire");
               this.mc_beam.visible = false;
               this.mc_blast.visible = false;
               this.mc_blast.gotoAndStop(1);
            }
            else if(this.anim == ANIM_FIRING)
            {
               this.mc_body.gotoAndStop("firing");
               this.mc_beam.graphics.clear();
               this.mc_beam.graphics.lineStyle(3,8921634);
               this.mc_beam.graphics.moveTo(this.pos.x,this.pos.y);
               this.mc_beam.graphics.lineTo(this.blast_pos.x,this.blast_pos.y);
               this.mc_blast.visible = true;
               this.mc_blast.gotoAndPlay(1);
               this.mc_blast.x = this.blast_pos.x;
               this.mc_blast.y = this.blast_pos.y;
               this.mc_blast.scaleX = this.mc_blast.scaleY = 0;
            }
         }
         if(this.anim == ANIM_FIRING)
         {
            this.mc_blast.scaleX = this.mc_blast.scaleY = this.blast_scale / 100;
         }
      }
   }
}

