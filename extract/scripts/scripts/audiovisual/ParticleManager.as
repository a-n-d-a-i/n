package audiovisual
{
   import math.vec2;
   
   public interface ParticleManager
   {
      
      function Spawn_FloorDust(param1:vec2, param2:Number, param3:vec2, param4:Number, param5:Number, param6:Number) : void;
      
      function Spawn_WallDust(param1:vec2, param2:Number, param3:vec2, param4:Number) : void;
      
      function Spawn_JumpDust(param1:Number, param2:Number, param3:Number) : void;
      
      function Spawn_LandDust(param1:Number, param2:Number, param3:Number, param4:Number) : void;
      
      function Spawn_BloodSpurt(param1:Number, param2:Number, param3:Number, param4:Number, param5:int) : void;
      
      function Spawn_RagBloodSpurt(param1:Number, param2:Number, param3:Number, param4:Number) : void;
      
      function Spawn_RagDust(param1:vec2, param2:Number, param3:Number, param4:Number, param5:Number) : void;
      
      function Spawn_RocketSmoke(param1:vec2, param2:Number) : void;
      
      function Spawn_Explosion(param1:vec2) : void;
      
      function Spawn_TurretBullet(param1:vec2, param2:vec2) : void;
      
      function Spawn_LaserSpark(param1:vec2, param2:Number, param3:Number) : void;
      
      function Spawn_LaserCharge(param1:vec2) : void;
      
      function Spawn_Zap(param1:Number, param2:Number, param3:Number) : void;
      
      function Spawn_ZapThwompH(param1:vec2, param2:Number, param3:Number) : void;
      
      function Spawn_ZapThwompV(param1:vec2, param2:Number, param3:Number) : void;
      
      function Spawn_ChainBullet(param1:vec2, param2:vec2) : void;
      
      function DEBUG_GetChildCount() : int;
   }
}

