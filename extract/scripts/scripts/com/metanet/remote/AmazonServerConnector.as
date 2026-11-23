package com.metanet.remote
{
   import com.foxarc.util.Base64;
   import com.metanet.ReplayCache;
   import com.metanet.data.AccountDetails;
   import com.metanet.data.Level;
   import com.metanet.events.NServerEvent;
   import com.metanet.global.RootURLS;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.TimerEvent;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.utils.ByteArray;
   import flash.utils.Timer;
   import org.robotlegs.mvcs.Actor;
   
   public class AmazonServerConnector extends Actor
   {
      
      [Inject]
      public var account:AccountDetails;
      
      [Inject]
      public var server:NServerConnector;
      
      [Inject]
      public var requestFactory:NRequestFactory;
      
      private var _key:String;
      
      private var _data:ByteArray;
      
      private var _amazonCredentials:Object = {};
      
      private var _boundary:String = "---------------------------546456346345634";
      
      private var _urlFromCredentials:String = "";
      
      private var _encodedData:String;
      
      private var _pendingReplayUser:int;
      
      private var _pendingReplaylevel:String;
      
      private var _replayCache:ReplayCache;
      
      private var _pendingReplayScore:int;
      
      private var _level:Level;
      
      private var _forcedDelay:Timer;
      
      private var _replayLevelID:String;
      
      private var _replayUserID:int;
      
      public function AmazonServerConnector()
      {
         super();
         this._replayCache = new ReplayCache();
         this._forcedDelay = new Timer(16,0);
      }
      
      public function uploadNewLevel(param1:Level) : void
      {
         this._level = param1;
         this._data = this._level.data;
         this._data.compress();
         this._encodedData = Base64.encode(this._data);
         this._data.uncompress();
         var _loc2_:NRequest = this.requestFactory.newLevel(this._level.name,this._encodedData.length);
         this.server.sendRequest(_loc2_);
      }
      
      public function uploadExistingLevel(param1:Level) : void
      {
         this._level = param1;
         this._data = this._level.data;
         this._data.compress();
         this._encodedData = Base64.encode(this._data);
         this._data.uncompress();
         var _loc2_:NRequest = this.requestFactory.uploadExistingLevel(this._level,this._encodedData.length);
         this.server.sendRequest(_loc2_);
      }
      
      public function uploadReplay(param1:String, param2:int, param3:ByteArray) : void
      {
         this._level = null;
         this._data = param3;
         this._data.compress();
         this._encodedData = Base64.encode(this._data);
         this._data.uncompress();
         this._replayCache.storeReplay(param1,Number(this.account.userID),param2,param3);
         var _loc4_:NRequest = this.requestFactory.submitScore(param1,param2,this._encodedData.length);
         this.server.sendRequest(_loc4_);
      }
      
      public function useCredentials(param1:XML) : void
      {
         var filename:String = null;
         var in_credentials:XML = param1;
         filename = in_credentials.xml.form..input.(name == "key").value.text();
         this._urlFromCredentials = in_credentials.xml.form.action.text();
         this._key = filename.substr(0,filename.length - 4);
         this.storeCredentials(in_credentials);
         if(this._level)
         {
            this._level.id = this._key;
         }
      }
      
      public function loadLevel(param1:String, param2:Boolean) : void
      {
         var _loc3_:Date = new Date();
         var _loc4_:* = RootURLS.levelsRoot + "/" + param1 + ".txt";
         if(param2)
         {
            _loc4_ += "?rnd=" + _loc3_.time + Math.random() * 1000;
         }
         var _loc5_:NRequest = new NRequest("loadLevel",new URLRequest(_loc4_));
         _loc5_.dataFormat = URLLoaderDataFormat.BINARY;
         _loc5_.successEvent = NServerEvent.LEVEL_DATA_LOADED;
         _loc5_.failEvent = NServerEvent.LEVEL_DATA_FAILED;
         this.server.sendRequest(_loc5_);
      }
      
      public function loadReplay(param1:String, param2:int, param3:int) : void
      {
         if(this._replayCache.hasReplay(param1,param2,param3))
         {
            this.pullReplayFromCache(param1,param2);
         }
         else
         {
            this.pullReplayFromServer(param1,param2,param3);
         }
      }
      
      private function pullReplayFromCache(param1:String, param2:int) : void
      {
         this._replayLevelID = param1;
         this._replayUserID = param2;
         this._forcedDelay.reset();
         this._forcedDelay.addEventListener(TimerEvent.TIMER,this.finishReplayFromCache);
         this._forcedDelay.start();
      }
      
      private function finishReplayFromCache(param1:TimerEvent) : void
      {
         this._forcedDelay.removeEventListener(TimerEvent.TIMER,this.finishReplayFromCache);
         this._forcedDelay.stop();
         dispatch(new NServerEvent(NServerEvent.REPLAY_DATA_LOADED,this._replayCache.getReplay(this._replayLevelID,this._replayUserID),null));
      }
      
      private function pullReplayFromServer(param1:String, param2:int, param3:int) : void
      {
         var _loc4_:URLLoader = new URLLoader();
         var _loc5_:Date = new Date();
         var _loc6_:String = RootURLS.replaysRoot + "/" + param1 + "-" + String(param2) + ".txt?rnd=" + _loc5_.time + Math.random() * 1000;
         _loc4_.dataFormat = URLLoaderDataFormat.TEXT;
         _loc4_.load(new URLRequest(_loc6_));
         _loc4_.addEventListener(Event.COMPLETE,this.handleReplayLoaded);
         _loc4_.addEventListener(IOErrorEvent.IO_ERROR,this.handleReplayDownloadError);
         this._pendingReplayUser = param2;
         this._pendingReplaylevel = param1;
         this._pendingReplayScore = param3;
      }
      
      private function handleReplayLoaded(param1:Event) : void
      {
         var _loc2_:URLLoader = URLLoader(param1.target);
         _loc2_.removeEventListener(Event.COMPLETE,this.handleReplayLoaded);
         var _loc3_:String = _loc2_.data;
         var _loc4_:ByteArray = Base64.decode(_loc3_);
         _loc4_.uncompress();
         this._replayCache.storeReplay(this._pendingReplaylevel,this._pendingReplayUser,this._pendingReplayScore,_loc4_);
         dispatch(new NServerEvent(NServerEvent.REPLAY_DATA_LOADED,_loc4_,null));
      }
      
      private function handleReplayDownloadError(param1:IOErrorEvent) : void
      {
         dispatch(new NServerEvent(NServerEvent.REPLAY_DATA_FAILED,null,null));
      }
      
      public function completeLevelUpload() : void
      {
         this.completeUpload(NServerEvent.LEVEL_UPLOAD_COMPLETE,NServerEvent.LEVEL_UPLOAD_FAILED);
      }
      
      public function completeReplayUpload() : void
      {
         this.completeUpload(NServerEvent.REPLAY_UPLOAD_COMPLETE,NServerEvent.REPLAY_UPLOAD_FAILED);
      }
      
      private function completeUpload(param1:String, param2:String) : void
      {
         var _loc4_:String = null;
         var _loc5_:MultiPartVariable = null;
         var _loc6_:NRequest = null;
         var _loc3_:Object = {};
         for(_loc4_ in this._amazonCredentials)
         {
            _loc3_[_loc4_] = this._amazonCredentials[_loc4_];
         }
         _loc5_ = new MultiPartVariable("file",this._encodedData);
         _loc5_.filename = this._key;
         _loc5_.contentType = "text/plain";
         _loc6_ = this.createAmazonRequest(_loc3_,_loc5_);
         _loc6_.successEvent = param1;
         _loc6_.failEvent = param2;
         this.server.sendRequest(_loc6_);
      }
      
      private function createAmazonRequest(param1:Object, param2:MultiPartVariable) : NRequest
      {
         var _loc4_:MultiPartVariable = null;
         var _loc5_:String = null;
         var _loc3_:MultiPartRequest = new MultiPartRequest(this._urlFromCredentials);
         _loc3_.boundary = this._boundary;
         for(_loc5_ in param1)
         {
            _loc4_ = new MultiPartVariable(_loc5_,param1[_loc5_]);
            _loc3_.add(_loc4_);
         }
         _loc3_.add(param2);
         return new NRequest("amazon",_loc3_.compose());
      }
      
      private function storeCredentials(param1:XML) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:XML = null;
         for each(_loc4_ in param1.xml.form..input)
         {
            _loc2_ = _loc4_.name.text();
            _loc3_ = _loc4_.value.text();
            this._amazonCredentials[_loc2_] = _loc3_;
         }
      }
   }
}

