package com.metanet.commands
{
   import com.metanet.data.AccountDetails;
   import com.metanet.data.EpisodeData;
   import com.metanet.data.Level;
   import com.metanet.data.Options;
   import com.metanet.events.MenuEvent;
   import com.metanet.events.StartEvent;
   import com.metanet.global.RootURLS;
   import com.metanet.remote.NRequestFactory;
   import com.metanet.remote.NServerConnector;
   import flash.display.LoaderInfo;
   import flash.display.Sprite;
   import flash.external.ExternalInterface;
   import flash.utils.ByteArray;
   import org.robotlegs.mvcs.Command;
   
   public class CheckLaunchDetails extends Command
   {
      
      [Inject]
      public var loaderInfo:LoaderInfo;
      
      [Inject]
      public var account:AccountDetails;
      
      [Inject]
      public var episodes:EpisodeData;
      
      [Inject]
      public var options:Options;
      
      [Inject]
      public var server:NServerConnector;
      
      [Inject]
      public var requestFactory:NRequestFactory;
      
      [Inject(named="uiStage")]
      public var uiStage:Sprite;
      
      public function CheckLaunchDetails()
      {
         super();
      }
      
      override public function execute() : void
      {
         if(this.isSiteInList(RootURLS.sitesWithDatabase))
         {
            this.checkAutolaunch();
         }
         else
         {
            this.account.isWeb = true;
            this.account.useDatabase = false;
            this.checkAutolaunch();
         }
      }
      
      private function isSiteInList(param1:Array) : Boolean
      {
         var _loc2_:int = 0;
         while(_loc2_ < param1.length)
         {
            if(this.aStartsWithB(this.loaderInfo.url,param1[_loc2_]))
            {
               return true;
            }
            _loc2_++;
         }
         return false;
      }
      
      private function checkAutolaunch() : void
      {
         if(!ExternalInterface.available || !this.isSiteInList(RootURLS.sitesWithAutoLaunch))
         {
            dispatch(new MenuEvent(MenuEvent.SHOW_MAIN_MENU));
            return;
         }
         var _loc1_:Object = this.getParametersFromURLBar();
         if(!_loc1_.l)
         {
            dispatch(new MenuEvent(MenuEvent.SHOW_MAIN_MENU));
            return;
         }
         var _loc2_:String = _loc1_.l;
         this.showControlDisplay();
         if(Number(_loc2_) < 1000)
         {
            this.launchBuiltInLevel(_loc2_);
         }
         else
         {
            this.launchUnloadedLevel(_loc2_);
         }
      }
      
      private function showControlDisplay() : void
      {
         var _loc1_:ControlDisplay = new ControlDisplay();
         _loc1_.x = 394;
         _loc1_.y = 135;
         this.uiStage.addChild(_loc1_);
      }
      
      private function getParametersFromURLBar() : Object
      {
         var _loc4_:Array = null;
         var _loc1_:String = ExternalInterface.call("document.location.search.toString");
         _loc1_ = _loc1_.substr(1);
         var _loc2_:Array = _loc1_.split("&");
         var _loc3_:Object = {};
         var _loc5_:int = 0;
         while(_loc5_ < _loc2_.length)
         {
            _loc4_ = _loc2_[_loc5_].split("=");
            _loc3_[unescape(_loc4_[0])] = unescape(_loc4_[1]);
            _loc5_++;
         }
         return _loc3_;
      }
      
      private function launchBuiltInLevel(param1:String) : void
      {
         var _loc2_:int = Number(param1);
         var _loc3_:int = (_loc2_ - 1) / 5;
         if(!this.episodes.isBeaten(_loc3_))
         {
            dispatch(new MenuEvent(MenuEvent.SHOW_MAIN_MENU));
            return;
         }
         var _loc4_:ByteArray = this.episodes.getLevelByID(param1);
         this.options.selectedLevel = new Level();
         this.options.selectedLevel.id = param1;
         this.options.selectedLevel.data = _loc4_;
         this.options.selectedLevel.minimumHighscore = int.MAX_VALUE;
         if(this.account.loggedIn)
         {
            this.server.sendRequest(this.requestFactory.getPersonalBestDetailsFor(this.options.selectedLevel));
         }
         var _loc5_:StartEvent = new StartEvent(StartEvent.START_LEVEL);
         _loc5_.levelData = _loc4_;
         _loc5_.levelID = param1;
         dispatch(_loc5_);
      }
      
      private function launchUnloadedLevel(param1:String) : void
      {
         var _loc2_:StartEvent = new StartEvent(StartEvent.START_UNLOADED_LEVEL);
         _loc2_.levelID = param1;
         dispatch(_loc2_);
      }
      
      private function aStartsWithB(param1:String, param2:String) : Boolean
      {
         return param1.indexOf(param2) == 0;
      }
   }
}

