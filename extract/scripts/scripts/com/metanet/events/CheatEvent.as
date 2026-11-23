package com.metanet.events
{
   import flash.events.Event;
   
   public class CheatEvent extends Event
   {
      
      public static const BEAT_ONE_HUNDRED:String = "beatOneHundred";
      
      public static const BEAT_EPISODE:String = "beatEpisode";
      
      public function CheatEvent(param1:String)
      {
         super(param1,false,false);
      }
   }
}

