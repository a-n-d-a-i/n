package com.metanet.events
{
   import com.metanet.remote.NRequest;
   import flash.events.Event;
   
   public class NServerEvent extends Event
   {
      
      public static const LOGIN_COMPLETE:String = "loginComplete";
      
      public static const READY_TO_SYNC:String = "readyToSync";
      
      public static const LOGOUT_COMPLETE:String = "logoutComplete";
      
      public static const SIGNUP_COMPLETE:String = "signupComplete";
      
      public static const RESET_COMPLETE:String = "resetComplete";
      
      public static const RATE_COMPLETE:String = "rateComplete";
      
      public static const FLAG_COMPLETE:String = "flagComplete";
      
      public static const NEW_LEVEL_COMPLETE:String = "newLevelComplete";
      
      public static const DELETE_LEVEL_COMPLETE:String = "deleteLevelComplete";
      
      public static const COMMIT_LEVEL_COMPLETE:String = "commitLevelComplete";
      
      public static const SAVE_LEVEL_COMPLETE:String = "saveLevelComplete";
      
      public static const UPDATE_LEVEL_COMPLETE:String = "updateLevelComplete";
      
      public static const SEARCH_COMPLETE:String = "searchComplete";
      
      public static const LEVEL_CREDENTIALS_OBTAINED:String = "levelCredentialsObtained";
      
      public static const LEVEL_CREDENTIALS_DENIED:String = "levelCredentialsDenied";
      
      public static const LEVEL_UPLOAD_COMPLETE:String = "levelUploadComplete";
      
      public static const LEVEL_UPLOAD_FAILED:String = "levelUploadFailed";
      
      public static const LEVEL_DATA_LOADED:String = "levelDataLoaded";
      
      public static const LEVEL_DATA_FAILED:String = "levelDataFailed";
      
      public static const REPLAY_CREDENTIALS_OBTAINED:String = "replayCredentialsObtained";
      
      public static const REPLAY_CREDENTIALS_DENIED:String = "replayCredentialsDenied";
      
      public static const REPLAY_UPLOAD_COMPLETE:String = "replayUploadComplete";
      
      public static const REPLAY_UPLOAD_FAILED:String = "replayUploadFailed";
      
      public static const REPLAY_DATA_LOADED:String = "repolayDataLoaded";
      
      public static const REPLAY_DATA_FAILED:String = "repolayDataFailed";
      
      public static const HIGHSCORES_LOADED:String = "highscoresLoaded";
      
      public static const EPISODE_UNLOCK_CONFIRMED:String = "episodeUnlockConfirmed";
      
      public static const EPISODE_DATA_COMPLETE:String = "episodeDataComplete";
      
      public static const EPISODE_DATA_FAILED:String = "episodeDataFailed";
      
      public static const FAVOURITE_COMPLETE:String = "favouriteComplete";
      
      public static const FAVOURITE_FAILED:String = "favouriteFailed";
      
      public static const UNFAVOURITE_COMPLETE:String = "unfavouriteComplete";
      
      public static const SERVER_SYNC_COMPLETE:String = "serverSyncComplete";
      
      public static const SERVER_SYNC_FAILED:String = "serverSyncFailed";
      
      public static const PERSONAL_BEST_RETRIEVED:String = "personalBestRetrieved";
      
      public static const PERSONAL_BEST_FAILED:String = "personalBestFailed";
      
      public static const TOKEN_EXPIRED:String = "tokenExpired";
      
      public var data:*;
      
      public var originalRequest:NRequest;
      
      public function NServerEvent(param1:String, param2:* = null, param3:NRequest = null)
      {
         super(param1);
         this.data = param2;
         this.originalRequest = param3;
      }
      
      public function get referenceLevel() : String
      {
         return this.originalRequest.referenceLevel;
      }
      
      public function get referenceUser() : int
      {
         return this.originalRequest.referenceUser;
      }
   }
}

