package com.metanet.remote
{
   import com.adobe.crypto.MD5;
   import com.metanet.data.AccountDetails;
   import com.metanet.data.Level;
   import com.metanet.data.Search;
   import com.metanet.events.NServerEvent;
   import com.metanet.global.RootURLS;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.net.URLVariables;
   import flash.utils.ByteArray;
   import org.robotlegs.mvcs.Actor;
   
   public class NRequestFactory extends Actor
   {
      
      [Inject]
      public var account:AccountDetails;
      
      private var Salt:Class = NRequestFactory_Salt;
      
      private var _salt:String;
      
      public function NRequestFactory()
      {
         super();
         var _loc1_:ByteArray = new this.Salt();
         this._salt = _loc1_.readUTFBytes(_loc1_.length);
      }
      
      public function signup(param1:String, param2:String, param3:String) : NRequest
      {
         var _loc4_:Object = {
            "email":param1,
            "username":param2,
            "password":param3
         };
         var _loc5_:URLRequest = this.createPostRequest("signup.php",_loc4_);
         var _loc6_:NRequest = new NRequest("signup",_loc5_);
         _loc6_.successEvent = NServerEvent.SIGNUP_COMPLETE;
         return _loc6_;
      }
      
      public function login(param1:String, param2:String) : NRequest
      {
         var _loc3_:Object = {
            "username":param1,
            "password":param2
         };
         var _loc4_:URLRequest = this.createPostRequest("login.php",_loc3_);
         var _loc5_:NRequest = new NRequest("login",_loc4_);
         _loc5_.successEvent = NServerEvent.LOGIN_COMPLETE;
         return _loc5_;
      }
      
      public function resetPasswordByUsername(param1:String) : NRequest
      {
         var _loc2_:Object = {"username":param1};
         var _loc3_:URLRequest = this.createPostRequest("password.php",_loc2_);
         var _loc4_:NRequest = new NRequest("resetPassword",_loc3_);
         _loc4_.successEvent = NServerEvent.RESET_COMPLETE;
         return _loc4_;
      }
      
      public function resetPasswordByEmail(param1:String) : NRequest
      {
         var _loc2_:Object = {"email":param1};
         var _loc3_:URLRequest = this.createPostRequest("password.php",_loc2_);
         var _loc4_:NRequest = new NRequest("resetPassword",_loc3_);
         _loc4_.successEvent = NServerEvent.RESET_COMPLETE;
         return _loc4_;
      }
      
      public function rateLevel(param1:String, param2:Number) : NRequest
      {
         var _loc3_:Object = {
            "l":param1,
            "r":param2,
            "u":this.account.cookie
         };
         var _loc4_:URLRequest = this.createPostRequest("rate.php",_loc3_);
         var _loc5_:NRequest = new NRequest("rateLevel",_loc4_);
         _loc5_.successEvent = NServerEvent.RATE_COMPLETE;
         _loc5_.referenceLevel = param1;
         return _loc5_;
      }
      
      public function flagLevel(param1:String) : NRequest
      {
         var _loc2_:Object = {
            "l":param1,
            "u":this.account.cookie
         };
         var _loc3_:URLRequest = this.createPostRequest("flag.php",_loc2_);
         var _loc4_:NRequest = new NRequest("flagLevel",_loc3_);
         _loc4_.successEvent = NServerEvent.FLAG_COMPLETE;
         _loc4_.referenceLevel = param1;
         return _loc4_;
      }
      
      public function favouriteLevel(param1:String) : NRequest
      {
         var _loc2_:Object = {
            "action":"save",
            "l":param1,
            "u":this.account.cookie
         };
         var _loc3_:URLRequest = this.createPostRequest("favorite.php",_loc2_);
         var _loc4_:NRequest = new NRequest("favouriteLevel",_loc3_);
         _loc4_.successEvent = NServerEvent.FAVOURITE_COMPLETE;
         _loc4_.failEvent = NServerEvent.FAVOURITE_FAILED;
         _loc4_.referenceLevel = param1;
         return _loc4_;
      }
      
      public function unfavouriteLevel(param1:String) : NRequest
      {
         var _loc2_:Object = {
            "action":"delete",
            "l":param1,
            "u":this.account.cookie
         };
         var _loc3_:URLRequest = this.createPostRequest("favorite.php",_loc2_);
         var _loc4_:NRequest = new NRequest("unfavouriteLevel",_loc3_);
         _loc4_.successEvent = NServerEvent.UNFAVOURITE_COMPLETE;
         _loc4_.referenceLevel = param1;
         return _loc4_;
      }
      
      public function finishedEpisode(param1:int) : NRequest
      {
         var _loc2_:Object = {
            "e":param1,
            "u":this.account.cookie
         };
         var _loc3_:URLRequest = this.createPostRequest("beaten.php",_loc2_);
         var _loc4_:NRequest = new NRequest("finishedEpisode",_loc3_);
         _loc4_.successEvent = NServerEvent.EPISODE_UNLOCK_CONFIRMED;
         return _loc4_;
      }
      
      public function getEpisodes() : NRequest
      {
         var _loc1_:Object = {"u":this.account.cookie};
         var _loc2_:URLRequest = this.createPostRequest("beaten.php",_loc1_);
         var _loc3_:NRequest = new NRequest("getEpisodes",_loc2_);
         _loc3_.successEvent = NServerEvent.EPISODE_DATA_COMPLETE;
         _loc3_.failEvent = NServerEvent.EPISODE_DATA_FAILED;
         return _loc3_;
      }
      
      public function flagReplay(param1:String, param2:int) : NRequest
      {
         var _loc3_:Object = {
            "l":param1,
            "r":param2,
            "u":this.account.cookie
         };
         var _loc4_:URLRequest = this.createPostRequest("flag.php",_loc3_);
         var _loc5_:NRequest = new NRequest("flagReplay",_loc4_);
         _loc5_.successEvent = NServerEvent.FLAG_COMPLETE;
         _loc5_.referenceLevel = param1;
         _loc5_.referenceUser = param2;
         return _loc5_;
      }
      
      public function submitScore(param1:String, param2:Number, param3:uint) : NRequest
      {
         var _loc4_:Object = {
            "l":param1,
            "s":param2,
            "length":param3,
            "u":this.account.cookie
         };
         var _loc5_:URLRequest = this.createPostRequest("submit_score.php",_loc4_);
         var _loc6_:NRequest = new NRequest("submitScore",_loc5_);
         _loc6_.successEvent = NServerEvent.REPLAY_CREDENTIALS_OBTAINED;
         _loc6_.failEvent = NServerEvent.REPLAY_CREDENTIALS_DENIED;
         _loc6_.referenceLevel = param1;
         return _loc6_;
      }
      
      public function newLevel(param1:String, param2:uint) : NRequest
      {
         var _loc3_:Object = {
            "action":"new",
            "name":param1,
            "genre":"Action",
            "length":param2,
            "u":this.account.cookie
         };
         var _loc4_:URLRequest = this.createPostRequest("submit_level.php",_loc3_);
         var _loc5_:NRequest = new NRequest("newLevel",_loc4_);
         _loc5_.successEvent = NServerEvent.LEVEL_CREDENTIALS_OBTAINED;
         _loc5_.failEvent = NServerEvent.LEVEL_CREDENTIALS_DENIED;
         return _loc5_;
      }
      
      public function deleteLevel(param1:Level) : NRequest
      {
         var _loc2_:Object = {
            "action":"delete",
            "l":param1.id,
            "u":this.account.cookie
         };
         var _loc3_:URLRequest = this.createPostRequest("submit_level.php",_loc2_);
         var _loc4_:NRequest = new NRequest("deleteLevel",_loc3_);
         _loc4_.successEvent = NServerEvent.DELETE_LEVEL_COMPLETE;
         _loc4_.referenceLevel = param1.id;
         return _loc4_;
      }
      
      public function commitLevel(param1:Level) : NRequest
      {
         var _loc2_:Object = {
            "action":"commit",
            "l":param1.id,
            "u":this.account.cookie
         };
         var _loc3_:URLRequest = this.createPostRequest("submit_level.php",_loc2_);
         var _loc4_:NRequest = new NRequest("commitLevel",_loc3_);
         _loc4_.successEvent = NServerEvent.COMMIT_LEVEL_COMPLETE;
         _loc4_.referenceLevel = param1.id;
         return _loc4_;
      }
      
      public function saveLevel(param1:Level) : NRequest
      {
         var _loc2_:Object = {
            "action":"save",
            "name":param1.name,
            "l":param1.id,
            "genre":"Action",
            "u":this.account.cookie
         };
         var _loc3_:URLRequest = this.createPostRequest("submit_level.php",_loc2_);
         var _loc4_:NRequest = new NRequest("saveLevel",_loc3_);
         _loc4_.successEvent = NServerEvent.LEVEL_CREDENTIALS_OBTAINED;
         _loc4_.referenceLevel = param1.id;
         return _loc4_;
      }
      
      public function updateLevel(param1:Level) : NRequest
      {
         var _loc2_:Object = {
            "action":"update",
            "name":param1.name,
            "l":param1.id,
            "genre":"Action",
            "u":this.account.cookie
         };
         var _loc3_:URLRequest = this.createPostRequest("submit_level.php",_loc2_);
         var _loc4_:NRequest = new NRequest("updateLevel",_loc3_);
         _loc4_.referenceLevel = param1.id;
         return _loc4_;
      }
      
      public function uploadExistingLevel(param1:Level, param2:uint) : NRequest
      {
         var _loc3_:Object = {
            "action":"save",
            "name":param1.name,
            "l":param1.id,
            "length":param2,
            "u":this.account.cookie
         };
         var _loc4_:URLRequest = this.createPostRequest("submit_level.php",_loc3_);
         var _loc5_:NRequest = new NRequest("saveLevel",_loc4_);
         _loc5_.successEvent = NServerEvent.LEVEL_CREDENTIALS_OBTAINED;
         _loc5_.failEvent = NServerEvent.LEVEL_CREDENTIALS_DENIED;
         _loc5_.referenceLevel = param1.id;
         return _loc5_;
      }
      
      public function logout() : NRequest
      {
         var _loc1_:URLRequest = this.createPostRequest("logout.php");
         var _loc2_:NRequest = new NRequest("logout",_loc1_);
         _loc2_.successEvent = NServerEvent.LOGOUT_COMPLETE;
         return _loc2_;
      }
      
      public function search(param1:Search) : NRequest
      {
         var _loc5_:String = null;
         var _loc2_:Object = {"u":this.account.cookie};
         var _loc3_:Object = {};
         var _loc4_:Object = param1.terms;
         for(_loc5_ in _loc4_)
         {
            if(_loc4_[_loc5_] != null)
            {
               _loc3_[_loc5_] = _loc4_[_loc5_];
            }
         }
         if(param1.mode == Search.FAVOURITES)
         {
            _loc3_["search[favorites]"] = "on";
         }
         else
         {
            _loc3_["sort"] = param1.sort;
         }
         _loc3_["offset"] = param1.offset;
         _loc3_["row_count"] = param1.rowCount;
         var _loc6_:URLRequest = this.createPostRequest("search.php",_loc2_,_loc3_);
         var _loc7_:NRequest = new NRequest("search",_loc6_);
         if(param1.mode != Search.FAVOURITES && param1.mode != Search.MY_LEVELS)
         {
            _loc7_.cachable = true;
         }
         _loc7_.cancelsPreviousRequests = true;
         _loc7_.successEvent = NServerEvent.SEARCH_COMPLETE;
         return _loc7_;
      }
      
      public function getBeatenLevels(param1:int, param2:Array) : NRequest
      {
         var _loc3_:Array = [];
         var _loc4_:int = param1 / 5;
         var _loc5_:int = 0;
         do
         {
            while((_loc4_ > 0 || !param2[_loc5_]) && _loc5_ < param2.length)
            {
               if(param2[_loc5_])
               {
                  _loc4_--;
               }
               _loc5_++;
            }
            _loc3_[_loc3_.length] = _loc5_;
            _loc5_++;
         }
         while(_loc3_.length < 2 && param2.indexOf(true) != param2.lastIndexOf(true) && _loc5_ < param2.length);
         
         var _loc6_:Object = {"u":this.account.cookie};
         var _loc7_:Object = {};
         _loc7_["l[0]"] = _loc3_[0] * 5 + 1;
         if(_loc3_.length > 1)
         {
            _loc7_["l[1]"] = _loc3_[1] * 5 + 1;
         }
         var _loc8_:URLRequest = this.createPostRequest("levels.php",_loc6_,_loc7_);
         var _loc9_:NRequest = new NRequest("getBeatenLevels",_loc8_);
         _loc9_.cachable = true;
         _loc9_.cancelsPreviousRequests = true;
         _loc9_.successEvent = NServerEvent.SEARCH_COMPLETE;
         return _loc9_;
      }
      
      public function requestHighscores(param1:String) : NRequest
      {
         var _loc2_:URLRequest = new URLRequest();
         _loc2_.method = URLRequestMethod.GET;
         _loc2_.url = this.createHighscoreURLForLevel(param1);
         var _loc3_:NRequest = new NRequest("highscores",_loc2_);
         _loc3_.cancelsPreviousRequests = true;
         _loc3_.successEvent = NServerEvent.HIGHSCORES_LOADED;
         _loc3_.dataFormat = URLLoaderDataFormat.BINARY;
         _loc3_.referenceLevel = param1;
         return _loc3_;
      }
      
      public function updateProgress(param1:Array) : NRequest
      {
         var _loc2_:Object = {};
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            if(param1[_loc3_] != -1)
            {
               _loc2_["b[" + _loc3_ + "]"] = param1[_loc3_] + _loc3_ * 10;
            }
            _loc3_++;
         }
         var _loc4_:URLRequest = this.createPostRequest("beaten.php",_loc2_);
         var _loc5_:NRequest = new NRequest("updateServerProgress",_loc4_);
         _loc5_.cachable = false;
         _loc5_.cancelsPreviousRequests = true;
         _loc5_.successEvent = NServerEvent.SERVER_SYNC_COMPLETE;
         _loc5_.failEvent = NServerEvent.SERVER_SYNC_FAILED;
         return _loc5_;
      }
      
      public function getPersonalBestDetailsFor(param1:Level) : NRequest
      {
         this.checkAccount();
         this.checkLevel(param1);
         var _loc2_:Object = {"u":this.account.cookie};
         var _loc3_:Object = {};
         _loc3_["l"] = param1.id;
         var _loc4_:URLRequest = this.createPostRequest("levels.php",_loc2_,_loc3_);
         var _loc5_:NRequest = new NRequest("getPersonalBestDetails",_loc4_);
         _loc5_.successEvent = NServerEvent.PERSONAL_BEST_RETRIEVED;
         _loc5_.failEvent = NServerEvent.PERSONAL_BEST_FAILED;
         _loc5_.referenceLevel = param1.id;
         return _loc5_;
      }
      
      private function checkAccount() : void
      {
         var _loc1_:String = this.account.cookie;
      }
      
      private function checkLevel(param1:Level) : void
      {
         var _loc2_:String = param1.id;
      }
      
      private function createPostRequest(param1:String, param2:Object = null, param3:Object = null) : URLRequest
      {
         var _loc4_:URLRequest = new URLRequest();
         _loc4_.method = URLRequestMethod.POST;
         _loc4_.url = RootURLS.serverRoot + param1;
         if(param2)
         {
            _loc4_.data = this.objectToVariables(param2);
         }
         if(param3)
         {
            _loc4_.url += this.objectToGetVariables(param3);
         }
         return _loc4_;
      }
      
      private function objectToGetVariables(param1:Object) : String
      {
         var _loc5_:String = null;
         var _loc6_:int = 0;
         var _loc2_:* = "?";
         var _loc3_:Boolean = true;
         var _loc4_:Array = [];
         for(_loc5_ in param1)
         {
            _loc4_.push(_loc5_);
         }
         _loc4_.sort();
         _loc6_ = 0;
         while(_loc6_ < _loc4_.length)
         {
            if(!_loc3_)
            {
               _loc2_ += "&";
            }
            _loc3_ = false;
            _loc2_ += _loc4_[_loc6_];
            _loc2_ += "=";
            _loc2_ += param1[_loc4_[_loc6_]];
            _loc6_++;
         }
         return _loc2_;
      }
      
      private function objectToVariables(param1:Object) : String
      {
         var _loc3_:String = null;
         var _loc2_:URLVariables = new URLVariables();
         for(_loc3_ in param1)
         {
            _loc2_[_loc3_] = param1[_loc3_];
         }
         return _loc2_.toString() + "&hex=" + MD5.hash(this._salt + unescape(_loc2_.toString()));
      }
      
      private function createHighscoreURLForLevel(param1:String) : String
      {
         var _loc3_:int = 0;
         var _loc2_:Array = param1.split("");
         while(_loc2_.length < 6)
         {
            _loc2_.unshift("0");
         }
         if(_loc2_.length > 6)
         {
            _loc3_ = _loc2_.length - 6;
         }
         var _loc4_:String = "";
         var _loc5_:int = 0;
         while(_loc5_ <= _loc3_)
         {
            _loc4_ += _loc2_[_loc5_];
            _loc5_++;
         }
         var _loc6_:String = _loc2_[1 + _loc3_] + _loc2_[2 + _loc3_];
         var _loc7_:String = _loc2_[3 + _loc3_] + _loc2_[4 + _loc3_] + _loc2_[5 + _loc3_];
         var _loc8_:Date = new Date();
         return RootURLS.serverRoot + "highscores/" + _loc4_ + "/" + _loc6_ + "/" + _loc7_ + ".txt?rnd=" + _loc8_.time + Math.random() * 1000;
      }
   }
}

