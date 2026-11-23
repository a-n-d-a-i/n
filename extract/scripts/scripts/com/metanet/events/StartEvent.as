package com.metanet.events
{
   import flash.events.Event;
   import flash.utils.ByteArray;
   
   public class StartEvent extends Event
   {
      
      public static const START_LEVEL:String = "StartLevel";
      
      public static const START_EPISODE:String = "StartEpisode";
      
      public static const START_CHALLENGE:String = "StartChallenge";
      
      public static const START_EDITOR:String = "StartEditor";
      
      public static const RESUME_EPISODE:String = "ResumeEpisode";
      
      public static const RESUME_CHALLENGE:String = "ResumeChallenge";
      
      public static const START_UNLOADED_LEVEL:String = "StartUnloadedLevel";
      
      public var gameMode:int;
      
      public var levelData:ByteArray;
      
      public var replayData:ByteArray;
      
      public var levelID:String;
      
      public function StartEvent(param1:String)
      {
         super(param1,false,false);
      }
      
      override public function clone() : Event
      {
         var _loc1_:StartEvent = new StartEvent(type);
         _loc1_.levelID = this.levelID;
         _loc1_.levelData = this.levelData;
         _loc1_.gameMode = this.gameMode;
         _loc1_.replayData = this.replayData;
         return _loc1_;
      }
   }
}

