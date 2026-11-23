package com.metanet.commands
{
   import com.metanet.events.CheatEvent;
   import com.metanet.events.InGameEvent;
   import com.metanet.events.InitializeEvent;
   import com.metanet.events.MenuEvent;
   import com.metanet.events.NServerEvent;
   import com.metanet.events.ReplayEvent;
   import com.metanet.events.SearchEvent;
   import com.metanet.events.StartEvent;
   import editor.EditorEvent;
   import org.robotlegs.core.ICommandMap;
   
   public class CommandMappings
   {
      
      public function CommandMappings()
      {
         super();
      }
      
      public static function mapCommands(param1:ICommandMap) : void
      {
         param1.mapEvent(InitializeEvent.INITIALIZE,StoreDefaults);
         param1.mapEvent(InitializeEvent.INITIALIZE,StoreDataFromSharedObject);
         param1.mapEvent(InitializeEvent.INITIALIZE,StoreMetanetLevelData);
         param1.mapEvent(InitializeEvent.INITIALIZE,StoreAttractModeReplays);
         param1.mapEvent(InitializeEvent.READY,CheckLaunchDetails);
         param1.mapEvent(InitializeEvent.READY,SubmitNextCachedLevel);
         param1.mapEvent(InitializeEvent.READY,SubmitLastCachedScore);
         param1.mapEvent(InitializeEvent.DELETED_CACHED_LEVEL,SubmitNextCachedLevel);
         param1.mapEvent(InitializeEvent.REUPLOAD_CACHED_LEVEL,SubmitLevelForUploadCredentials);
         param1.mapEvent(InitializeEvent.DELETED_CACHED_SCORE,SubmitLastCachedScore);
         param1.mapEvent(InitializeEvent.REUPLOAD_CACHED_SCORE,SubmitScoreForUploadCredentials);
         param1.mapEvent(InitializeEvent.CACHED_SCORE_CORRUPTED,DeleteScoreFromCache);
         param1.mapEvent(MenuEvent.RESET_LOCAL_DATA,ResetLocalData);
         param1.mapEvent(MenuEvent.STORE_DEFAULTS,StoreDefaults);
         param1.mapEvent(MenuEvent.LOGIN,Login);
         param1.mapEvent(MenuEvent.LOGOUT,Logout);
         param1.mapEvent(MenuEvent.SIGNUP,Signup);
         param1.mapEvent(MenuEvent.PUBLISH_LEVEL,PublishSelectedLevel);
         param1.mapEvent(MenuEvent.DELETE_LEVEL,DeleteSelectedLevel);
         param1.mapEvent(MenuEvent.DELETE_LEVEL,DeleteSelectedLevelFromCache);
         param1.mapEvent(NServerEvent.LEVEL_CREDENTIALS_OBTAINED,SubmitLevelToAmazon);
         param1.mapEvent(NServerEvent.LEVEL_CREDENTIALS_OBTAINED,CheckForMaximumLevels);
         param1.mapEvent(NServerEvent.REPLAY_CREDENTIALS_OBTAINED,SubmitReplayToAmazon);
         param1.mapEvent(NServerEvent.LOGIN_COMPLETE,StoreLoginResult);
         param1.mapEvent(NServerEvent.READY_TO_SYNC,SynchronizeWithServer);
         param1.mapEvent(NServerEvent.LOGOUT_COMPLETE,StoreLogoutResult);
         param1.mapEvent(NServerEvent.SEARCH_COMPLETE,StoreSearchResults);
         param1.mapEvent(NServerEvent.LEVEL_DATA_LOADED,StoreLevelData);
         param1.mapEvent(NServerEvent.LEVEL_DATA_FAILED,StoreLevelData);
         param1.mapEvent(NServerEvent.PERSONAL_BEST_RETRIEVED,StorePersonalBest);
         param1.mapEvent(NServerEvent.REPLAY_DATA_LOADED,WatchSpecificReplay);
         param1.mapEvent(NServerEvent.EPISODE_DATA_COMPLETE,StoreEpisodesBeaten);
         param1.mapEvent(NServerEvent.EPISODE_DATA_FAILED,StartOfflineMode);
         param1.mapEvent(NServerEvent.DELETE_LEVEL_COMPLETE,RemoveLevelFromSearch);
         param1.mapEvent(NServerEvent.COMMIT_LEVEL_COMPLETE,RemoveLevelFromSearch);
         param1.mapEvent(NServerEvent.TOKEN_EXPIRED,Login);
         param1.mapEvent(NServerEvent.LEVEL_UPLOAD_COMPLETE,DeleteSelectedLevelFromCache);
         param1.mapEvent(NServerEvent.REPLAY_UPLOAD_COMPLETE,DeleteScoreFromCache);
         param1.mapEvent(InGameEvent.COMPLETE_EPISODE,BeatEpisode);
         param1.mapEvent(InGameEvent.SUBMIT_SCORE,CacheHighscoreLocally);
         param1.mapEvent(InGameEvent.SUBMIT_SCORE,SubmitScoreForUploadCredentials);
         param1.mapEvent(ReplayEvent.WATCH,DownloadReplay);
         param1.mapEvent(ReplayEvent.FLAG,FlagReplay);
         param1.mapEvent(ReplayEvent.RANDOM,WatchRandomReplay);
         param1.mapEvent(ReplayEvent.NEXT,WatchNextReplay);
         param1.mapEvent(SearchEvent.INITIATE_SEARCH,InitiateSearch);
         param1.mapEvent(SearchEvent.LOAD_NEXT_LEVEL,DownloadNextLevel);
         param1.mapEvent(CheatEvent.BEAT_EPISODE,BeatEpisode);
         param1.mapEvent(EditorEvent.EVENT_SAVE,SubmitLevelForUploadCredentials);
         param1.mapEvent(EditorEvent.EVENT_SAVE,CacheLevelLocally);
         param1.mapEvent(StartEvent.START_EPISODE,StartEpisode);
         param1.mapEvent(StartEvent.START_CHALLENGE,StartChallenge);
         param1.mapEvent(StartEvent.START_UNLOADED_LEVEL,PrepareUserLevelForAutolaunch);
         param1.mapEvent(StartEvent.START_LEVEL,StartLevel);
         param1.mapEvent(StartEvent.START_EDITOR,StartEditor);
         param1.mapEvent(StartEvent.RESUME_EPISODE,ResumeEpisode);
         param1.mapEvent(StartEvent.RESUME_CHALLENGE,ResumeChallenge);
      }
   }
}

