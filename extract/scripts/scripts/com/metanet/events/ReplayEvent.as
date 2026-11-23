package com.metanet.events
{
   import flash.events.Event;
   
   public class ReplayEvent extends Event
   {
      
      public static const WATCH:String = "replayWatch";
      
      public static const FLAG:String = "replayFlag";
      
      public static const RANDOM:String = "replayRandom";
      
      public static const NEXT:String = "replayNext";
      
      public var level:String;
      
      public var user:int;
      
      public var score:int;
      
      public function ReplayEvent(param1:String)
      {
         super(param1,bubbles,cancelable);
      }
      
      override public function clone() : Event
      {
         var _loc1_:ReplayEvent = new ReplayEvent(type);
         _loc1_.level = this.level;
         _loc1_.user = this.user;
         _loc1_.score = this.score;
         return _loc1_;
      }
   }
}

