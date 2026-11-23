package math
{
   public class mathutils
   {
      
      private static var rnd_seed:uint = 1;
      
      public function mathutils()
      {
         super();
      }
      
      public static function SetRandomSeed(param1:uint) : void
      {
         if(param1 == 0 || param1 > 2147483646)
         {
            trace("WARNING! Some idiot is trying to seed the PRNG with an invalid value: " + param1);
            rnd_seed = 1;
         }
         else
         {
            rnd_seed = param1;
         }
      }
      
      public static function GenerateNewRandomSeed() : void
      {
         var _loc1_:uint = uint(1 + uint(Math.random() * Number(2147483645)));
         SetRandomSeed(_loc1_);
      }
      
      public static function GetRandomSeed() : uint
      {
         return rnd_seed;
      }
      
      public static function Random() : Number
      {
         return gen() / 2147483647;
      }
      
      private static function gen() : uint
      {
         return rnd_seed = rnd_seed * 16807 % 2147483647;
      }
      
      public static function DegToRad(param1:Number) : Number
      {
         return param1 * (Math.PI / 180);
      }
      
      public static function RadToDeg(param1:Number) : Number
      {
         return param1 * (180 / Math.PI);
      }
      
      public static function WrapAngle_Shortest(param1:Number) : Number
      {
         while(Math.PI < Math.abs(param1))
         {
            if(param1 < 0)
            {
               param1 += 2 * Math.PI;
            }
            else
            {
               param1 -= 2 * Math.PI;
            }
         }
         return param1;
      }
      
      public static function WrapAngle_Directed(param1:Number, param2:Number) : Number
      {
         if(0 < param2)
         {
            return WrapAngle_Pos(param1);
         }
         if(param2 < 0)
         {
            while(param1 > 0 || param1 < -Math.PI * 2)
            {
               if(param1 > 0)
               {
                  param1 -= 2 * Math.PI;
               }
               else if(-2 * Math.PI > param1)
               {
                  param1 += 2 * Math.PI;
               }
            }
            return param1;
         }
         trace("WARNING! WrapAngle_Directed() was passed a null-dir!: " + param2);
         return 0;
      }
      
      public static function WrapAngle_Pos(param1:Number) : Number
      {
         while(param1 < 0 || param1 > Math.PI * 2)
         {
            if(param1 < 0)
            {
               param1 += 2 * Math.PI;
            }
            else if(2 * Math.PI < param1)
            {
               param1 -= 2 * Math.PI;
            }
         }
         return param1;
      }
      
      public static function InterpolateOrn(param1:Number, param2:Number, param3:Number, param4:Number = 0) : Number
      {
         var _loc5_:Number = WrapAngle_Pos(param1);
         var _loc6_:Number = WrapAngle_Pos(param2);
         var _loc7_:Number = _loc6_ - _loc5_;
         if(param4 == 0)
         {
            _loc7_ = WrapAngle_Shortest(_loc7_);
         }
         else
         {
            _loc7_ = WrapAngle_Directed(_loc7_,param4);
         }
         _loc7_ *= param3;
         return _loc5_ + _loc7_;
      }
   }
}

