package com.metanet.global
{
   import flash.display.BitmapData;
   
   public class Flavours
   {
      
      private static var _flavourImage:BitmapData;
      
      private static var _p1Colors:Array = [];
      
      private static var _p2Colors:Array = [];
      
      private static var NinjaFlavours:Class = Flavours_NinjaFlavours;
      
      public function Flavours()
      {
         super();
      }
      
      public static function getP1Flavour(param1:int) : uint
      {
         if(!_flavourImage)
         {
            readImage();
         }
         return _p1Colors[param1];
      }
      
      public static function getP2Flavour(param1:int) : uint
      {
         if(!_flavourImage)
         {
            readImage();
         }
         return _p2Colors[param1];
      }
      
      private static function readImage() : void
      {
         _flavourImage = new NinjaFlavours().bitmapData;
         var _loc1_:int = 0;
         while(_loc1_ < _flavourImage.width)
         {
            _p1Colors[_loc1_] = _flavourImage.getPixel(_loc1_,0);
            _p2Colors[_loc1_] = _flavourImage.getPixel(_loc1_,1);
            _loc1_++;
         }
      }
   }
}

