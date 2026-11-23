package com.metanet.events
{
   import flash.events.Event;
   
   public class ConfirmationEvent extends Event
   {
      
      public static const CONFIRM_ACTION:String = "confirm";
      
      public var message:String;
      
      public var yesEvent:Event;
      
      public var noEvent:Event;
      
      public function ConfirmationEvent(param1:String)
      {
         super(param1,false,false);
      }
   }
}

