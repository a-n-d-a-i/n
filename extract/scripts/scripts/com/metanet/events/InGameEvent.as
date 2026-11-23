package com.metanet.events
{
   import flash.events.Event;
   
   public class InGameEvent extends Event
   {
      
      public static var COMPLETE_EPISODE:String = "completeEpisode";
      
      public static var SUBMIT_SCORE:String = "submitScore";
      
      public function InGameEvent(param1:String)
      {
         super(param1,false,false);
      }
      
      override public function clone() : Event
      {
         return new InGameEvent(type);
      }
   }
}

