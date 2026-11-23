package com.metanet.events
{
   import flash.events.Event;
   
   public class InitializeEvent extends Event
   {
      
      public static const INITIALIZE:String = "initialize";
      
      public static const READY:String = "ready";
      
      public static const REUPLOAD_CACHED_LEVEL:String = "reuploadCachedLevel";
      
      public static const DELETED_CACHED_LEVEL:String = "deletedCachedLevel";
      
      public static const REUPLOAD_CACHED_SCORE:String = "reuploadCachedScore";
      
      public static const DELETED_CACHED_SCORE:String = "deletedCachedScore";
      
      public static const SHARED_OBJECT_FAILED:String = "failedObjectFailed";
      
      public static const CACHED_SCORE_CORRUPTED:String = "cachedScoreCorrupted";
      
      public function InitializeEvent(param1:String)
      {
         super(param1);
      }
      
      override public function clone() : Event
      {
         return new InitializeEvent(type);
      }
   }
}

