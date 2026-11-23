package com.goldengear.utils
{
   import com.gskinner.utils.Rndm;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.ColorTransform;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.getDefinitionByName;
   
   public class GeneralUtils
   {
      
      private static var mode:String;
      
      private static const DEBUG:String = "debug";
      
      private static const RELEASE:String = "release";
      
      public function GeneralUtils()
      {
         super();
      }
      
      public static function launchGoldenGearSite(param1:MouseEvent = null) : void
      {
         navigateToURL(new URLRequest("http://www.goldengeargames.com/"),"_blank");
      }
      
      public static function pickRandomFromArray(param1:Array) : *
      {
         var _loc2_:int = Math.floor(Math.random() * param1.length);
         return param1[_loc2_];
      }
      
      public static function pickSeededRandomFromArray(param1:Array) : *
      {
         var _loc2_:int = Math.floor(Rndm.random() * param1.length);
         return param1[_loc2_];
      }
      
      public static function randomBetween(param1:Number, param2:Number) : Number
      {
         var _loc3_:Number = param2 - param1;
         return Math.random() * _loc3_ + param1;
      }
      
      public static function get isDebug() : Boolean
      {
         if(!mode)
         {
            updateMode();
         }
         return mode == DEBUG;
      }
      
      private static function updateMode() : void
      {
         var re:RegExp = null;
         var debug:Boolean = false;
         try
         {
            throw new Error("Setting global debug flag...");
         }
         catch(e:Error)
         {
            re = /\[.*:[0-9]+\]/;
            debug = Boolean(re.test(e.getStackTrace()));
            if(debug)
            {
               mode = DEBUG;
            }
            else
            {
               mode = RELEASE;
            }
         }
      }
      
      public static function removeFromArray(param1:*, param2:Array) : void
      {
         var _loc3_:int = 0;
         if(param2 != null && param1 != null)
         {
            _loc3_ = int(param2.indexOf(param1));
            param2.splice(_loc3_,1);
         }
      }
      
      public static function isInArray(param1:*, param2:Array) : Boolean
      {
         if(param2.indexOf(param1) == -1)
         {
            return false;
         }
         return true;
      }
      
      public static function getMovieClipFromLibrary(param1:String) : MovieClip
      {
         var _loc2_:Class = getDefinitionByName(param1) as Class;
         return new _loc2_();
      }
      
      public static function getDomainFromURL(param1:String) : String
      {
         var _loc2_:Number = param1.indexOf("://") + 3;
         var _loc3_:Number = Number(param1.indexOf("/",_loc2_));
         var _loc4_:String = param1.substring(_loc2_,_loc3_);
         var _loc5_:Number = _loc4_.lastIndexOf(".") - 1;
         var _loc6_:Number = _loc4_.lastIndexOf(".",_loc5_) + 1;
         return _loc4_.substring(_loc6_,_loc4_.length);
      }
      
      public static function setTint(param1:DisplayObject, param2:uint, param3:Number) : void
      {
         var _loc4_:ColorTransform = new ColorTransform();
         _loc4_.redMultiplier = 1 - param3;
         _loc4_.greenMultiplier = 1 - param3;
         _loc4_.blueMultiplier = 1 - param3;
         _loc4_.redOffset = Math.round(((param2 & 0xFF0000) >> 16) * param3);
         _loc4_.greenOffset = Math.round(((param2 & 0xFF00) >> 8) * param3);
         _loc4_.blueOffset = Math.round((param2 & 0xFF) * param3);
         param1.transform.colorTransform = _loc4_;
      }
      
      public static function removeTint(param1:DisplayObject) : void
      {
         param1.transform.colorTransform = new ColorTransform();
      }
      
      public static function debugTrace(param1:String, param2:Boolean = true) : void
      {
         if(param2)
         {
            trace(param1);
         }
      }
      
      public static function createSquare(param1:Number, param2:uint) : Sprite
      {
         var _loc3_:Sprite = new Sprite();
         _loc3_.graphics.beginFill(param2);
         _loc3_.graphics.drawRect(0,0,param1,param1);
         _loc3_.graphics.endFill();
         return _loc3_;
      }
      
      public static function createTextField(param1:int = 150, param2:int = 30) : TextField
      {
         var _loc4_:TextField = null;
         var _loc3_:TextFormat = new TextFormat();
         _loc3_.font = "Arial";
         _loc3_.bold = true;
         _loc3_.color = 0;
         _loc4_ = new TextField();
         _loc4_.width = param1;
         _loc4_.height = param2;
         _loc4_.selectable = false;
         _loc4_.mouseEnabled = false;
         _loc4_.defaultTextFormat = _loc3_;
         return _loc4_;
      }
      
      public static function smartDestroy(param1:DisplayObjectContainer) : void
      {
         var skippedObjects:int;
         var obj:DisplayObject = null;
         var destroyFunc:Function = null;
         var in_clip:DisplayObjectContainer = param1;
         if(!in_clip)
         {
            return;
         }
         skippedObjects = 0;
         while(in_clip.numChildren > skippedObjects)
         {
            obj = in_clip.getChildAt(skippedObjects);
            if(obj)
            {
               try
               {
                  if(obj.hasOwnProperty("destroy"))
                  {
                     destroyFunc = obj["destroy"];
                     if(destroyFunc != null)
                     {
                        destroyFunc();
                        if(obj.parent == in_clip)
                        {
                           trace(obj + " didn\'t remove itself from its parent on destroy()");
                           in_clip.removeChild(obj);
                        }
                     }
                     else
                     {
                        in_clip.removeChild(obj);
                     }
                  }
                  else
                  {
                     in_clip.removeChild(obj);
                  }
               }
               catch(e:Error)
               {
                  trace("Failed to destroy object.",e);
                  if(obj.parent == in_clip)
                  {
                     skippedObjects++;
                  }
                  continue;
               }
            }
         }
         if(in_clip.parent)
         {
            in_clip.parent.removeChild(in_clip);
         }
      }
      
      public static function randomizeArray(param1:Array) : Array
      {
         var _loc2_:int = 0;
         var _loc3_:* = undefined;
         var _loc4_:Array = [];
         var _loc5_:Array = param1.concat();
         while(_loc5_.length > 0)
         {
            _loc2_ = Math.floor(Math.random() * _loc5_.length);
            _loc3_ = _loc5_[_loc2_];
            _loc4_[_loc4_.length] = _loc3_;
            _loc5_.splice(_loc2_,1);
         }
         return _loc4_;
      }
      
      public static function createArrayOfInts(param1:int) : Array
      {
         var _loc2_:Array = [];
         var _loc3_:int = 0;
         while(_loc3_ < param1)
         {
            _loc2_[_loc3_] = _loc3_;
            _loc3_++;
         }
         return _loc2_;
      }
   }
}

