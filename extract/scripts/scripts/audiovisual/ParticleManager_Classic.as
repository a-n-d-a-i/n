package audiovisual
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import math.vec2;
   
   public class ParticleManager_Classic implements ParticleManager
   {
      
      private static const MAX_PARTICLE_SCALE:Number = 64;
      
      public static const FXTYPE_SKIDDUST:int = 0;
      
      public static const FXTYPE_JUMPDUST:int = 1;
      
      public static const FXTYPE_BLOODSPURT:int = 2;
      
      public static const FXTYPE_RAGDUST:int = 3;
      
      public static const FXTYPE_CHAINBULLET:int = 4;
      
      public static const FXTYPE_CHAINDEBRIS:int = 5;
      
      public static const FXTYPE_CHAINFLASH:int = 6;
      
      public static const FXTYPE_LASERSPARK:int = 7;
      
      public static const FXTYPE_LASERCHARGE:int = 8;
      
      public static const FXTYPE_ZAP:int = 9;
      
      public static const FXTYPE_ZAPV:int = 10;
      
      public static const FXTYPE_TURRETBULLET:int = 11;
      
      public static const FXTYPE_TURRETDEBRIS:int = 12;
      
      public static const FXTYPE_FIREBURST:int = 13;
      
      public static const FXTYPE_FIREBALL:int = 14;
      
      public static const FXTYPE_ROCKETSMOKE:int = 15;
      
      private static const NUM_FXTYPES:int = 16;
      
      private static const BUFFER_BACK:int = 0;
      
      private static const BUFFER_FRONT:int = 1;
      
      private static const MAX_PARTICLES:int = 100;
      
      private static const mcList:Vector.<Vector.<Class>> = new Vector.<Vector.<Class>>(NUM_FXTYPES,true);
      
      private static const bufferList:Vector.<int> = new Vector.<int>(NUM_FXTYPES,true);
      
      mcList[FXTYPE_SKIDDUST] = new Vector.<Class>(2,true);
      mcList[FXTYPE_SKIDDUST][0] = asset_gfx_fx_dust0;
      mcList[FXTYPE_SKIDDUST][1] = asset_gfx_fx_dust1;
      mcList[FXTYPE_JUMPDUST] = new Vector.<Class>(2,true);
      mcList[FXTYPE_JUMPDUST][0] = asset_gfx_fx_dust0;
      mcList[FXTYPE_JUMPDUST][1] = asset_gfx_fx_dust1;
      mcList[FXTYPE_BLOODSPURT] = new Vector.<Class>(2,true);
      mcList[FXTYPE_BLOODSPURT][0] = asset_gfx_fx_blood0;
      mcList[FXTYPE_BLOODSPURT][1] = asset_gfx_fx_blood1;
      mcList[FXTYPE_RAGDUST] = new Vector.<Class>(2,true);
      mcList[FXTYPE_RAGDUST][0] = asset_gfx_fx_dust0;
      mcList[FXTYPE_RAGDUST][1] = asset_gfx_fx_dust1;
      mcList[FXTYPE_CHAINBULLET] = new Vector.<Class>(1,true);
      mcList[FXTYPE_CHAINBULLET][0] = asset_gfx_fx_chain_bullet;
      mcList[FXTYPE_CHAINDEBRIS] = new Vector.<Class>(3,true);
      mcList[FXTYPE_CHAINDEBRIS][0] = asset_gfx_fx_chain_debris0;
      mcList[FXTYPE_CHAINDEBRIS][1] = asset_gfx_fx_chain_debris1;
      mcList[FXTYPE_CHAINDEBRIS][2] = asset_gfx_fx_chain_debris2;
      mcList[FXTYPE_CHAINFLASH] = new Vector.<Class>(2,true);
      mcList[FXTYPE_CHAINFLASH][0] = asset_gfx_fx_chain_flash0;
      mcList[FXTYPE_CHAINFLASH][1] = asset_gfx_fx_chain_flash1;
      mcList[FXTYPE_LASERSPARK] = new Vector.<Class>(3,true);
      mcList[FXTYPE_LASERSPARK][0] = asset_gfx_fx_laser_spark0;
      mcList[FXTYPE_LASERSPARK][1] = asset_gfx_fx_laser_spark1;
      mcList[FXTYPE_LASERSPARK][2] = asset_gfx_fx_laser_spark2;
      mcList[FXTYPE_LASERCHARGE] = new Vector.<Class>(3,true);
      mcList[FXTYPE_LASERCHARGE][0] = asset_gfx_fx_laser_charge0;
      mcList[FXTYPE_LASERCHARGE][1] = asset_gfx_fx_laser_charge1;
      mcList[FXTYPE_LASERCHARGE][2] = asset_gfx_fx_laser_charge2;
      mcList[FXTYPE_ZAP] = new Vector.<Class>(3,true);
      mcList[FXTYPE_ZAP][0] = asset_gfx_fx_zap0;
      mcList[FXTYPE_ZAP][1] = asset_gfx_fx_zap1;
      mcList[FXTYPE_ZAP][2] = asset_gfx_fx_zap2;
      mcList[FXTYPE_ZAPV] = new Vector.<Class>(3,true);
      mcList[FXTYPE_ZAPV][0] = asset_gfx_fx_zapv0;
      mcList[FXTYPE_ZAPV][1] = asset_gfx_fx_zapv1;
      mcList[FXTYPE_ZAPV][2] = asset_gfx_fx_zapv2;
      mcList[FXTYPE_TURRETBULLET] = new Vector.<Class>(1,true);
      mcList[FXTYPE_TURRETBULLET][0] = asset_gfx_fx_turret_bullet;
      mcList[FXTYPE_TURRETDEBRIS] = new Vector.<Class>(1,true);
      mcList[FXTYPE_TURRETDEBRIS][0] = asset_gfx_fx_turret_debris0;
      mcList[FXTYPE_FIREBURST] = new Vector.<Class>(2,true);
      mcList[FXTYPE_FIREBURST][0] = asset_gfx_fx_fireburst0;
      mcList[FXTYPE_FIREBURST][1] = asset_gfx_fx_fireburst1;
      mcList[FXTYPE_FIREBALL] = new Vector.<Class>(3,true);
      mcList[FXTYPE_FIREBALL][0] = asset_gfx_fx_fireball0;
      mcList[FXTYPE_FIREBALL][1] = asset_gfx_fx_fireball1;
      mcList[FXTYPE_FIREBALL][2] = asset_gfx_fx_fireball2;
      mcList[FXTYPE_ROCKETSMOKE] = new Vector.<Class>(3,true);
      mcList[FXTYPE_ROCKETSMOKE][0] = asset_gfx_fx_rocket_smoke0;
      mcList[FXTYPE_ROCKETSMOKE][1] = asset_gfx_fx_rocket_smoke1;
      mcList[FXTYPE_ROCKETSMOKE][2] = asset_gfx_fx_rocket_smoke2;
      bufferList[FXTYPE_SKIDDUST] = BUFFER_BACK;
      bufferList[FXTYPE_JUMPDUST] = BUFFER_FRONT;
      bufferList[FXTYPE_BLOODSPURT] = BUFFER_FRONT;
      bufferList[FXTYPE_RAGDUST] = BUFFER_BACK;
      bufferList[FXTYPE_CHAINBULLET] = BUFFER_FRONT;
      bufferList[FXTYPE_CHAINDEBRIS] = BUFFER_FRONT;
      bufferList[FXTYPE_CHAINFLASH] = BUFFER_FRONT;
      bufferList[FXTYPE_LASERSPARK] = BUFFER_FRONT;
      bufferList[FXTYPE_LASERCHARGE] = BUFFER_FRONT;
      bufferList[FXTYPE_ZAP] = BUFFER_FRONT;
      bufferList[FXTYPE_ZAPV] = BUFFER_FRONT;
      bufferList[FXTYPE_TURRETBULLET] = BUFFER_FRONT;
      bufferList[FXTYPE_TURRETDEBRIS] = BUFFER_FRONT;
      bufferList[FXTYPE_FIREBURST] = BUFFER_FRONT;
      bufferList[FXTYPE_FIREBALL] = BUFFER_FRONT;
      bufferList[FXTYPE_ROCKETSMOKE] = BUFFER_FRONT;
      
      private var buffers:Vector.<Sprite>;
      
      public function ParticleManager_Classic(param1:Sprite, param2:Sprite)
      {
         super();
         this.buffers = new Vector.<Sprite>(2,true);
         this.buffers[BUFFER_BACK] = param1;
         this.buffers[BUFFER_FRONT] = param2;
      }
      
      public function DEBUG_GetChildCount() : int
      {
         return this.buffers[BUFFER_BACK].numChildren + this.buffers[BUFFER_FRONT].numChildren;
      }
      
      private function SpawnParticle_Random(param1:int, param2:Number) : MovieClip
      {
         if(Math.random() <= param2)
         {
            return this.SpawnParticle(param1);
         }
         return null;
      }
      
      private function SpawnParticle(param1:int) : MovieClip
      {
         var _loc2_:MovieClip = new mcList[param1][Math.floor(Math.random() * mcList[param1].length)]() as MovieClip;
         this.buffers[bufferList[param1]].addChild(_loc2_);
         return _loc2_;
      }
      
      private function SpawnParticle_Limit(param1:int) : MovieClip
      {
         if(this.buffers[bufferList[param1]].numChildren < MAX_PARTICLES)
         {
            return this.SpawnParticle(param1);
         }
         return null;
      }
      
      public function Spawn_FloorDust(param1:vec2, param2:Number, param3:vec2, param4:Number, param5:Number, param6:Number) : void
      {
         var _loc7_:MovieClip = this.SpawnParticle_Random(FXTYPE_SKIDDUST,0.2);
         if(_loc7_ != null)
         {
            _loc7_.x = param1.x - param3.x * param2;
            _loc7_.y = param1.y - param3.y * param2;
            _loc7_.rotation = param4 - param5 * 8 + (Math.random() * 10 - 5);
            _loc7_.scaleX = Math.min(64,param5 * Math.min(MAX_PARTICLE_SCALE,10 + param6 * 10) / 100);
            _loc7_.scaleY = 10 / 100;
         }
      }
      
      public function Spawn_WallDust(param1:vec2, param2:Number, param3:vec2, param4:Number) : void
      {
         var _loc5_:MovieClip = this.SpawnParticle_Random(FXTYPE_SKIDDUST,0.3);
         if(_loc5_ != null)
         {
            _loc5_.x = param1.x - param3.x * param2;
            _loc5_.y = param1.y - param3.y * param2 - (Math.random() * param2 * 2 - param2);
            _loc5_.rotation = 90 - param3.x * 8 + (Math.random() * 10 - 5);
            _loc5_.scaleX = Math.min(MAX_PARTICLE_SCALE,10 + param4 * 20) / 100;
            _loc5_.scaleY = 10 / 100;
         }
      }
      
      public function Spawn_JumpDust(param1:Number, param2:Number, param3:Number) : void
      {
         var _loc6_:MovieClip = null;
         var _loc4_:int = 1;
         var _loc5_:int = 0;
         while(_loc5_ <= 4)
         {
            _loc6_ = this.SpawnParticle(FXTYPE_JUMPDUST);
            _loc6_.x = param1;
            _loc6_.y = param2;
            _loc6_.rotation = param3 - _loc4_ * 20 + (Math.random() * 20 - 10);
            _loc6_.scaleX = _loc4_ * (10 + Math.random() * 8) / 100;
            _loc6_.scaleY = (10 + Math.random() * 5) / 100;
            _loc4_ *= -1;
            _loc5_++;
         }
      }
      
      public function Spawn_LandDust(param1:Number, param2:Number, param3:Number, param4:Number) : void
      {
         var _loc7_:MovieClip = null;
         var _loc5_:int = 1;
         var _loc6_:int = 0;
         while(_loc6_ <= 4)
         {
            _loc7_ = this.SpawnParticle(FXTYPE_JUMPDUST);
            _loc7_.x = param1;
            _loc7_.y = param2;
            _loc7_.rotation = param3 - _loc5_ * 40 + (Math.random() * 20 - 10);
            _loc7_.scaleX = _loc5_ * (5 + Math.random() * 5 + param4) / 100;
            _loc7_.scaleY = (15 + param4 * 2) / 100;
            _loc5_ *= -1;
            _loc6_++;
         }
      }
      
      public function Spawn_BloodSpurt(param1:Number, param2:Number, param3:Number, param4:Number, param5:int) : void
      {
         var _loc7_:MovieClip = null;
         var _loc6_:int = 0;
         while(_loc6_ <= param5)
         {
            _loc7_ = this.SpawnParticle_Limit(FXTYPE_BLOODSPURT);
            if(_loc7_ != null)
            {
               _loc7_.x = param1 - (Math.random() * 8 - 4);
               _loc7_.y = param2 - (Math.random() * 8 - 4);
               _loc7_.scaleX = Math.min(MAX_PARTICLE_SCALE,Math.max(-MAX_PARTICLE_SCALE,param3 * (6 + Math.random() * 3) - (Math.random() * 60 - 30))) / 100;
               _loc7_.scaleY = Math.min(MAX_PARTICLE_SCALE,Math.max(-MAX_PARTICLE_SCALE,param4 * (6 + Math.random() * 3) - (Math.random() * 60 - 30))) / 100;
            }
            _loc6_++;
         }
      }
      
      public function Spawn_RagBloodSpurt(param1:Number, param2:Number, param3:Number, param4:Number) : void
      {
         var _loc5_:MovieClip = this.SpawnParticle_Limit(FXTYPE_BLOODSPURT);
         if(_loc5_ != null)
         {
            _loc5_.x = param1 - (Math.random() * 8 - 4);
            _loc5_.y = param2 - (Math.random() * 8 - 4);
            _loc5_.scaleX = Math.min(MAX_PARTICLE_SCALE,Math.max(-MAX_PARTICLE_SCALE,param3 * (6 + Math.random() * 3) - (Math.random() * 40 - 20))) / 100;
            _loc5_.scaleY = Math.min(MAX_PARTICLE_SCALE,Math.max(-MAX_PARTICLE_SCALE,param4 * (6 + Math.random() * 3) - (Math.random() * 40 - 20))) / 100;
         }
      }
      
      public function Spawn_RagDust(param1:vec2, param2:Number, param3:Number, param4:Number, param5:Number) : void
      {
         var _loc6_:MovieClip = this.SpawnParticle_Random(FXTYPE_RAGDUST,0.2);
         if(_loc6_ != null)
         {
            param3 /= param5;
            param4 /= param5;
            _loc6_.x = param1.x - param3 * param2;
            _loc6_.y = param1.y - param4 * param2;
            _loc6_.rotation = Math.atan2(param4,param3) / Math.PI * 180 + (Math.random() * 20 - 10);
            _loc6_.scaleX = Math.min(MAX_PARTICLE_SCALE,20 + 2 * param5) / 100;
            _loc6_.scaleY = 10 / 100;
         }
      }
      
      public function Spawn_RocketSmoke(param1:vec2, param2:Number) : void
      {
         var _loc3_:MovieClip = this.SpawnParticle_Random(FXTYPE_ROCKETSMOKE,0.2);
         if(_loc3_ != null)
         {
            _loc3_.x = param1.x;
            _loc3_.y = param1.y;
            _loc3_.rotation = param2 + 10 * (Math.random() * 2 - 1);
            _loc3_.scaleX = (20 + Math.random() * 20) / 100;
            _loc3_.scaleY = (20 + Math.random() * 20) / 100;
         }
      }
      
      public function Spawn_Explosion(param1:vec2) : void
      {
         var _loc2_:MovieClip = this.SpawnParticle(FXTYPE_FIREBURST);
         var _loc3_:MovieClip = this.SpawnParticle(FXTYPE_FIREBALL);
         var _loc4_:MovieClip = this.SpawnParticle(FXTYPE_FIREBALL);
         var _loc5_:MovieClip = this.SpawnParticle(FXTYPE_FIREBALL);
         var _loc6_:MovieClip = this.SpawnParticle(FXTYPE_FIREBALL);
         _loc2_.x = _loc3_.x = _loc4_.x = _loc5_.x = _loc6_.x = param1.x;
         _loc2_.y = _loc3_.y = _loc4_.y = _loc5_.y = _loc6_.y = param1.y;
         var _loc7_:Number = Math.random();
         var _loc8_:Number = Math.random();
         var _loc9_:Number = Math.random();
         var _loc10_:Number = Math.random();
         var _loc11_:Number = Math.random();
         _loc2_.scaleX = (15 + _loc7_ * 15) / 100;
         _loc2_.scaleY = (15 + _loc8_ * 15) / 100;
         _loc3_.scaleX = _loc4_.scaleX = (20 + _loc9_ * 20) / 100;
         _loc5_.scaleX = _loc6_.scaleX = (20 + _loc10_ * 30) / 100;
         _loc3_.scaleY = _loc6_.scaleY = (20 + _loc11_ * 20) / 100;
         _loc4_.scaleY = _loc5_.scaleY = (20 + _loc7_ * 10) / 100;
         _loc3_.rotation = 360 * _loc7_;
         _loc4_.rotation = 360 * _loc8_;
         _loc5_.rotation = 360 * _loc11_;
         _loc6_.rotation = 360 * _loc9_;
      }
      
      public function Spawn_TurretBullet(param1:vec2, param2:vec2) : void
      {
         var _loc3_:MovieClip = this.SpawnParticle(FXTYPE_TURRETBULLET);
         _loc3_.x = param1.x;
         _loc3_.y = param1.y;
         _loc3_.scaleX = (param2.x - param1.x) / 100;
         _loc3_.scaleY = (param2.y - param1.y) / 100;
         var _loc4_:MovieClip = this.SpawnParticle(FXTYPE_TURRETDEBRIS);
         var _loc5_:MovieClip = this.SpawnParticle(FXTYPE_TURRETDEBRIS);
         _loc4_.x = _loc5_.x = param2.x;
         _loc4_.y = _loc5_.y = param2.y;
         _loc4_.scaleX = _loc5_.scaleY = (40 + Math.random() * 20) / 100;
         _loc5_.scaleX = _loc4_.scaleY = (20 + Math.random() * 40) / 100;
         var _loc6_:Number = Math.atan2(param1.y - param2.y,param1.x - param2.x) / Math.PI * 180;
         _loc4_.rotation = _loc6_ + (5 + Math.random() * 15);
         _loc5_.rotation = _loc6_ - (5 + Math.random() * 15);
      }
      
      public function Spawn_LaserSpark(param1:vec2, param2:Number, param3:Number) : void
      {
         var _loc4_:MovieClip = this.SpawnParticle_Random(FXTYPE_LASERSPARK,0.75);
         if(_loc4_ != null)
         {
            _loc4_.x = param1.x;
            _loc4_.y = param1.y;
            _loc4_.scaleX = -param2 * (30 + 40 * (Math.random() * 2 - 1)) / 100;
            _loc4_.scaleY = -param3 * (30 + 40 * (Math.random() * 2 - 1)) / 100;
         }
      }
      
      public function Spawn_LaserCharge(param1:vec2) : void
      {
         var _loc2_:MovieClip = this.SpawnParticle_Random(FXTYPE_LASERCHARGE,0.9);
         if(_loc2_ != null)
         {
            _loc2_.x = param1.x;
            _loc2_.y = param1.y;
            _loc2_.scaleX = (20 + Math.random() * 20) / 100;
            _loc2_.scaleY = (10 + Math.random() * 20) / 100;
            _loc2_.rotation = Math.random() * 360;
         }
      }
      
      public function Spawn_Zap(param1:Number, param2:Number, param3:Number) : void
      {
         var _loc5_:MovieClip = null;
         var _loc4_:int = 0;
         while(_loc4_ <= 4)
         {
            _loc5_ = this.SpawnParticle_Limit(FXTYPE_ZAP);
            if(_loc5_ != null)
            {
               _loc5_.x = param1;
               _loc5_.y = param2;
               _loc5_.scaleX = (30 + Math.random() * 30) / 100;
               _loc5_.scaleY = (30 + Math.random() * 20) / 100;
               _loc5_.rotation = param3 + 20 * (Math.random() * 2 - 1);
            }
            _loc4_++;
         }
      }
      
      public function Spawn_ZapThwompH(param1:vec2, param2:Number, param3:Number) : void
      {
         var _loc5_:MovieClip = null;
         var _loc4_:int = 0;
         while(_loc4_ <= 4)
         {
            _loc5_ = this.SpawnParticle_Limit(FXTYPE_ZAP);
            if(_loc5_ != null)
            {
               _loc5_.x = param1.x + param2;
               _loc5_.y = param1.y - param3 + param3 * Math.random();
               _loc5_.scaleX = (4 * param2 + 20 * (Math.random() * 2 - 1)) / 100;
               _loc5_.scaleY = (60 + 60 * Math.random()) / 100;
            }
            _loc4_++;
         }
      }
      
      public function Spawn_ZapThwompV(param1:vec2, param2:Number, param3:Number) : void
      {
         var _loc5_:MovieClip = null;
         var _loc4_:int = 0;
         while(_loc4_ <= 4)
         {
            _loc5_ = this.SpawnParticle_Limit(FXTYPE_ZAPV);
            if(_loc5_ != null)
            {
               _loc5_.y = param1.y + param3;
               _loc5_.x = param1.x - param2 + param2 * Math.random();
               _loc5_.scaleY = (4 * param3 + 20 * (Math.random() * 2 - 1)) / 100;
               _loc5_.scaleX = (60 + 60 * Math.random()) / 100;
            }
            _loc4_++;
         }
      }
      
      public function Spawn_ChainBullet(param1:vec2, param2:vec2) : void
      {
         var _loc3_:Number = Math.random() * 2 - 1;
         var _loc4_:Number = Math.random() * 2 - 1;
         var _loc5_:Number = Math.random() * 2 - 1;
         var _loc6_:MovieClip = this.SpawnParticle(FXTYPE_CHAINFLASH);
         var _loc7_:MovieClip = this.SpawnParticle(FXTYPE_CHAINBULLET);
         var _loc8_:vec2 = param1.To(param2);
         var _loc9_:Number = _loc8_.Len();
         var _loc10_:Number = Math.atan2(_loc8_.y,_loc8_.x) / Math.PI * 180;
         _loc7_.scaleX = _loc9_ / 100;
         _loc6_.x = _loc7_.x = param1.x;
         _loc6_.y = _loc7_.y = param1.y;
         _loc6_.scaleX = (30 + _loc3_ * 10) / 100;
         _loc6_.scaleY = (20 + _loc4_ * 20) / 100;
         _loc6_.rotation = _loc7_.rotation = _loc10_;
         var _loc11_:MovieClip = this.SpawnParticle(FXTYPE_CHAINDEBRIS);
         var _loc12_:MovieClip = this.SpawnParticle(FXTYPE_CHAINDEBRIS);
         _loc11_.x = _loc12_.x = param2.x;
         _loc11_.y = _loc12_.y = param2.y;
         _loc11_.scaleX = (30 + 15 * _loc4_) / 100;
         _loc12_.scaleX = (30 + 15 * _loc5_) / 100;
         _loc10_ -= 180;
         _loc11_.rotation = _loc10_ + 15 * _loc3_;
         _loc12_.rotation = _loc10_ + 15 * _loc4_;
      }
   }
}

