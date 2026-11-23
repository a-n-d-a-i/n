package audiovisual.entitygraphics
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.geom.ColorTransform;
   import flash.media.SoundTransform;
   import math.vec2;
   import simulation.ninja.Ninja;
   
   public class EntityGraphics_Ninja implements EntityGraphics
   {
      
      public static const ANIM_STANDING:int = 0;
      
      public static const ANIM_RUNNING:int = 1;
      
      public static const ANIM_SKIDDING:int = 2;
      
      public static const ANIM_INAIR:int = 3;
      
      public static const ANIM_WALLSLIDING:int = 4;
      
      public static const ANIM_DEAD:int = 5;
      
      public static const ANIM_CELEBRATING:int = 6;
      
      public static const ANIM_OFF:int = 7;
      
      public static const RAGDOLL_BODY:int = 0;
      
      public static const RAGDOLL_ARM_R:int = 1;
      
      public static const RAGDOLL_ARM_L:int = 2;
      
      public static const RAGDOLL_LEG_R:int = 3;
      
      public static const RAGDOLL_LEG_L:int = 4;
      
      private var entity:Ninja;
      
      private var sndLoopMC:MovieClip;
      
      private var sndMC:MovieClip;
      
      private var mc_sprite:MovieClip;
      
      private var ragdoll_mcList:Vector.<MovieClip>;
      
      public var ragdoll_posList:Vector.<vec2>;
      
      public var ragdoll_lenList:Vector.<Number>;
      
      public var ragdoll_ornList:Vector.<Number>;
      
      private var ragdoll_flipList:Vector.<Number>;
      
      public var pos:vec2;
      
      public var vel:Number;
      
      public var orn:Number;
      
      public var anim:int;
      
      public var facing:int;
      
      private var run_anim_leftovers:Number;
      
      private var scaling_factor:Number;
      
      private var prev_frame:int;
      
      public function EntityGraphics_Ninja(param1:Ninja, param2:uint)
      {
         super();
         this.sndLoopMC = new asset_sfx_playerLoopMC();
         this.sndMC = new asset_sfx_playerMC();
         this.entity = param1;
         this.mc_sprite = new asset_gfx_ninja();
         this.mc_sprite.gotoAndPlay("STAND");
         this.pos = new vec2();
         this.vel = 0;
         this.orn = 0;
         this.facing = 1;
         this.anim = ANIM_STANDING;
         this.run_anim_leftovers = 0;
         this.scaling_factor = 0.2;
         this.prev_frame = 1;
         this.ragdoll_mcList = new Vector.<MovieClip>(5,true);
         this.ragdoll_mcList[RAGDOLL_BODY] = new asset_gfx_ragdoll_body();
         this.ragdoll_mcList[RAGDOLL_ARM_R] = new asset_gfx_ragdoll_arm();
         this.ragdoll_mcList[RAGDOLL_ARM_L] = new asset_gfx_ragdoll_arm();
         this.ragdoll_mcList[RAGDOLL_LEG_R] = new asset_gfx_ragdoll_leg();
         this.ragdoll_mcList[RAGDOLL_LEG_L] = new asset_gfx_ragdoll_leg();
         this.ragdoll_posList = new Vector.<vec2>(5,true);
         this.ragdoll_posList[RAGDOLL_BODY] = new vec2();
         this.ragdoll_posList[RAGDOLL_ARM_R] = new vec2();
         this.ragdoll_posList[RAGDOLL_ARM_L] = new vec2();
         this.ragdoll_posList[RAGDOLL_LEG_R] = new vec2();
         this.ragdoll_posList[RAGDOLL_LEG_L] = new vec2();
         this.ragdoll_lenList = new Vector.<Number>(5,true);
         this.ragdoll_lenList[RAGDOLL_BODY] = 0;
         this.ragdoll_lenList[RAGDOLL_ARM_R] = 0;
         this.ragdoll_lenList[RAGDOLL_ARM_L] = 0;
         this.ragdoll_lenList[RAGDOLL_LEG_R] = 0;
         this.ragdoll_lenList[RAGDOLL_LEG_L] = 0;
         this.ragdoll_ornList = new Vector.<Number>(5,true);
         this.ragdoll_ornList[RAGDOLL_BODY] = 0;
         this.ragdoll_ornList[RAGDOLL_ARM_R] = 0;
         this.ragdoll_ornList[RAGDOLL_ARM_L] = 0;
         this.ragdoll_ornList[RAGDOLL_LEG_R] = 0;
         this.ragdoll_ornList[RAGDOLL_LEG_L] = 0;
         this.ragdoll_flipList = new Vector.<Number>(5,true);
         this.ragdoll_flipList[RAGDOLL_BODY] = -1;
         this.ragdoll_flipList[RAGDOLL_ARM_R] = 1;
         this.ragdoll_flipList[RAGDOLL_ARM_L] = 1;
         this.ragdoll_flipList[RAGDOLL_LEG_R] = -1;
         this.ragdoll_flipList[RAGDOLL_LEG_L] = -1;
         var _loc3_:ColorTransform = new ColorTransform();
         _loc3_.color = param2;
         this.mc_sprite.transform.colorTransform = _loc3_;
         var _loc4_:int = 0;
         while(_loc4_ < this.ragdoll_mcList.length)
         {
            this.ragdoll_mcList[_loc4_].transform.colorTransform = _loc3_;
            _loc4_++;
         }
      }
      
      public function HACKY_PlayOneshotSound(param1:String) : void
      {
         this.sndMC.gotoAndPlay(param1);
      }
      
      public function get hasValidPose() : Boolean
      {
         if(!this.mc_sprite.shoulder)
         {
            return false;
         }
         if(!this.mc_sprite.pelvis)
         {
            return false;
         }
         if(!this.mc_sprite.handR)
         {
            return false;
         }
         if(!this.mc_sprite.handL)
         {
            return false;
         }
         if(!this.mc_sprite.footR)
         {
            return false;
         }
         if(!this.mc_sprite.footL)
         {
            return false;
         }
         return true;
      }
      
      public function NINJA_GetCurrentPose(param1:Vector.<vec2>, param2:Vector.<vec2>) : void
      {
         var _loc3_:int = this.mc_sprite.currentFrame;
         param1[0] = new vec2(this.mc_sprite.shoulder.x,this.mc_sprite.shoulder.y);
         param1[1] = new vec2(this.mc_sprite.pelvis.x,this.mc_sprite.pelvis.y);
         param1[2] = new vec2(this.mc_sprite.handR.x,this.mc_sprite.handR.y);
         param1[3] = new vec2(this.mc_sprite.handL.x,this.mc_sprite.handL.y);
         param1[4] = new vec2(this.mc_sprite.footR.x,this.mc_sprite.footR.y);
         param1[5] = new vec2(this.mc_sprite.footL.x,this.mc_sprite.footL.y);
         this.mc_sprite.gotoAndStop(this.prev_frame);
         param2[0] = new vec2(param1[0].x - this.mc_sprite.shoulder.x,param1[0].y - this.mc_sprite.shoulder.y);
         param2[1] = new vec2(param1[1].x - this.mc_sprite.pelvis.x,param1[1].y - this.mc_sprite.pelvis.y);
         param2[2] = new vec2(param1[2].x - this.mc_sprite.handR.x,param1[2].y - this.mc_sprite.handR.y);
         param2[3] = new vec2(param1[3].x - this.mc_sprite.handL.x,param1[3].y - this.mc_sprite.handL.y);
         param2[4] = new vec2(param1[4].x - this.mc_sprite.footR.x,param1[4].y - this.mc_sprite.footR.y);
         param2[5] = new vec2(param1[5].x - this.mc_sprite.footL.x,param1[5].y - this.mc_sprite.footL.y);
         var _loc4_:int = 0;
         while(_loc4_ < 6)
         {
            param1[_loc4_].Scale(this.scaling_factor);
            param2[_loc4_].Scale(this.scaling_factor);
            _loc4_++;
         }
      }
      
      public function RegisterGraphics(param1:Vector.<DisplayObject>) : void
      {
         param1.push(this.mc_sprite);
         var _loc2_:int = 0;
         while(_loc2_ < this.ragdoll_mcList.length)
         {
            param1.push(this.ragdoll_mcList[_loc2_]);
            _loc2_++;
         }
      }
      
      public function Hide() : void
      {
         this.mc_sprite.visible = false;
         var _loc1_:int = 0;
         while(_loc1_ < this.ragdoll_mcList.length)
         {
            this.ragdoll_mcList[_loc1_].visible = false;
            _loc1_++;
         }
      }
      
      public function UpdateState() : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:SoundTransform = null;
         var _loc7_:SoundTransform = null;
         var _loc8_:int = 0;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:int = 0;
         var _loc13_:Number = NaN;
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         var _loc16_:Number = NaN;
         var _loc17_:int = 0;
         var _loc18_:Number = NaN;
         var _loc19_:int = 0;
         var _loc20_:int = 0;
         var _loc1_:int = this.anim;
         this.entity.GFX_UpdateState(this);
         if(this.anim == ANIM_OFF)
         {
            this.mc_sprite.visible = false;
            _loc2_ = 0;
            while(_loc2_ < this.ragdoll_mcList.length)
            {
               this.ragdoll_mcList[_loc2_].visible = false;
               _loc2_++;
            }
         }
         else if(this.anim == ANIM_DEAD)
         {
            this.sndLoopMC.gotoAndPlay("wallslide_stop");
            this.sndLoopMC.gotoAndPlay("skid_stop");
            this.mc_sprite.visible = false;
            _loc3_ = 0;
            while(_loc3_ < this.ragdoll_mcList.length)
            {
               this.ragdoll_mcList[_loc3_].visible = true;
               this.ragdoll_mcList[_loc3_].x = this.ragdoll_posList[_loc3_].x;
               this.ragdoll_mcList[_loc3_].y = this.ragdoll_posList[_loc3_].y;
               this.ragdoll_mcList[_loc3_].scaleX = this.scaling_factor;
               this.ragdoll_mcList[_loc3_].scaleY = this.ragdoll_flipList[_loc3_] * this.facing * this.scaling_factor;
               this.ragdoll_mcList[_loc3_].rotation = this.ragdoll_ornList[_loc3_] / Math.PI * 180;
               this.ragdoll_mcList[_loc3_].gotoAndStop(1 + Math.floor(100 * this.ragdoll_lenList[_loc3_]));
               _loc3_++;
            }
         }
         else
         {
            this.prev_frame = this.mc_sprite.currentFrame;
            this.mc_sprite.visible = true;
            _loc4_ = 0;
            while(_loc4_ < this.ragdoll_mcList.length)
            {
               this.ragdoll_mcList[_loc4_].visible = false;
               _loc4_++;
            }
            this.mc_sprite.x = this.pos.x;
            this.mc_sprite.y = this.pos.y;
            this.mc_sprite.scaleX = this.facing * this.scaling_factor;
            this.mc_sprite.scaleY = this.scaling_factor;
            this.mc_sprite.rotation = this.orn / Math.PI * 180;
            if(this.anim != _loc1_)
            {
               if(_loc1_ == ANIM_WALLSLIDING)
               {
                  this.sndLoopMC.gotoAndPlay("wallslide_stop");
               }
               else if(_loc1_ == ANIM_SKIDDING)
               {
                  this.sndLoopMC.gotoAndPlay("skid_stop");
               }
               if(this.anim == ANIM_STANDING)
               {
                  this.mc_sprite.gotoAndPlay("STAND");
               }
               else if(this.anim == ANIM_SKIDDING)
               {
                  this.mc_sprite.gotoAndStop("SKID");
                  this.sndLoopMC.soundTransform.volume = 0;
                  this.sndLoopMC.gotoAndPlay("skid_start");
               }
               else if(this.anim == ANIM_WALLSLIDING)
               {
                  this.mc_sprite.gotoAndStop("WALLSLIDE");
                  this.sndLoopMC.soundTransform.volume = 0;
                  this.sndLoopMC.gotoAndPlay("wallslide_start");
               }
               else if(this.anim == ANIM_RUNNING)
               {
                  this.mc_sprite.gotoAndStop("RUN");
               }
               else if(this.anim == ANIM_CELEBRATING)
               {
                  _loc5_ = Math.floor(Math.random() * 999) % 9 + 1;
                  this.mc_sprite.gotoAndPlay("CELEBRATE_NEW" + _loc5_);
               }
            }
            if(this.anim == ANIM_WALLSLIDING)
            {
               _loc6_ = new SoundTransform(Math.min(1,Math.abs(this.vel * 0.7)));
               this.sndLoopMC.soundTransform = _loc6_;
            }
            else if(this.anim == ANIM_SKIDDING)
            {
               _loc7_ = new SoundTransform(Math.min(1,Math.abs(this.vel)));
               this.sndLoopMC.soundTransform = _loc7_;
            }
            if(this.anim == ANIM_INAIR)
            {
               _loc8_ = 94;
               _loc9_ = -1 * (40 / 60);
               _loc10_ = 2.5 * (40 / 60);
               _loc11_ = 0;
               if(this.vel < 0)
               {
                  if(this.vel < _loc9_)
                  {
                     _loc11_ = -1;
                  }
                  else
                  {
                     _loc11_ = -(this.vel / _loc9_);
                  }
               }
               else if(_loc10_ < this.vel)
               {
                  _loc11_ = 1;
               }
               else
               {
                  _loc11_ = Math.sqrt(this.vel / _loc10_);
               }
               _loc12_ = Math.floor(_loc11_ * 9);
               this.mc_sprite.gotoAndStop(_loc8_ + _loc12_);
            }
            else if(this.anim == ANIM_RUNNING)
            {
               _loc13_ = this.vel;
               _loc14_ = 13;
               _loc15_ = 72;
               _loc16_ = 0.9;
               _loc17_ = this.mc_sprite.currentFrame - _loc14_;
               _loc18_ = _loc13_ / _loc16_;
               _loc18_ = _loc18_ + this.run_anim_leftovers;
               _loc19_ = Math.floor(_loc18_);
               this.run_anim_leftovers = _loc18_ - _loc19_;
               _loc20_ = (_loc17_ + _loc19_) % _loc15_;
               this.mc_sprite.gotoAndStop(_loc14_ + _loc20_);
            }
         }
      }
   }
}

