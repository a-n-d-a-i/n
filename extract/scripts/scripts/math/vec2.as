package math
{
   public class vec2
   {
      
      public var x:Number;
      
      public var y:Number;
      
      public function vec2(param1:Number = 0, param2:Number = 0)
      {
         super();
         this.x = param1;
         this.y = param2;
      }
      
      public static function FromDir(param1:Number) : vec2
      {
         return new vec2(Math.cos(param1),Math.sin(param1));
      }
      
      public static function VecTo(param1:vec2, param2:vec2) : vec2
      {
         return new vec2(param2.x - param1.x,param2.y - param1.y);
      }
      
      public function VecPerp(param1:vec2) : vec2
      {
         return new vec2(-param1.y,param1.x);
      }
      
      public function VecDot(param1:vec2, param2:vec2) : Number
      {
         return param1.x * param2.x + param1.y * param2.y;
      }
      
      public function To(param1:vec2) : vec2
      {
         return new vec2(param1.x - this.x,param1.y - this.y);
      }
      
      public function Perp() : vec2
      {
         return new vec2(-this.y,this.x);
      }
      
      public function PerpDot(param1:vec2) : Number
      {
         return -this.y * param1.x + this.x * param1.y;
      }
      
      public function Clone() : vec2
      {
         return new vec2(this.x,this.y);
      }
      
      public function Plus(param1:vec2) : vec2
      {
         return new vec2(this.x + param1.x,this.y + param1.y);
      }
      
      public function Minus(param1:vec2) : vec2
      {
         return new vec2(this.x - param1.x,this.y - param1.y);
      }
      
      public function Dot(param1:vec2) : Number
      {
         return this.x * param1.x + this.y * param1.y;
      }
      
      public function Len() : Number
      {
         return Math.sqrt(this.x * this.x + this.y * this.y);
      }
      
      public function LenSq() : Number
      {
         return this.x * this.x + this.y * this.y;
      }
      
      public function ToString() : String
      {
         return "(" + this.x + "," + this.y + ")";
      }
      
      public function Copy(param1:vec2) : void
      {
         this.x = param1.x;
         this.y = param1.y;
      }
      
      public function Normalize() : void
      {
         var _loc1_:Number = Math.sqrt(this.x * this.x + this.y * this.y);
         if(_loc1_ != 0)
         {
            this.x /= _loc1_;
            this.y /= _loc1_;
         }
      }
      
      public function Scale(param1:Number) : void
      {
         this.x *= param1;
         this.y *= param1;
      }
   }
}

