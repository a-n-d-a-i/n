package com.metanet.events
{
   import flash.events.Event;
   
   public class KeyboardFocusEvent extends Event
   {
      
      public static var FOCUS_IN:String = "keyFocusIn";
      
      public static var FOCUS_OUT:String = "keyFocusOut";
      
      public function KeyboardFocusEvent(param1:String)
      {
         super(param1,false,false);
      }
   }
}

