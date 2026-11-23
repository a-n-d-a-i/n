package com.metanet.remote
{
   import com.metanet.data.AccountDetails;
   import com.metanet.events.NServerEvent;
   import flash.events.Event;
   import flash.events.HTTPStatusEvent;
   import flash.events.IOErrorEvent;
   import flash.events.TimerEvent;
   import flash.net.URLLoader;
   import flash.utils.Timer;
   import org.robotlegs.mvcs.Actor;
   
   public class NServerConnector extends Actor
   {
      
      [Inject]
      public var account:AccountDetails;
      
      private var _requests:Vector.<NRequest>;
      
      private var _cache:Object = {};
      
      private var _loader:URLLoader;
      
      private var _activeRequest:NRequest;
      
      private var _cacheDelay:Timer;
      
      private var _ignoreActiveRequest:Boolean;
      
      public function NServerConnector()
      {
         super();
         this._loader = new URLLoader();
         this._loader.addEventListener(Event.COMPLETE,this.handleRequestComplete);
         this._loader.addEventListener(IOErrorEvent.IO_ERROR,this.handleRequestError);
         this._loader.addEventListener(HTTPStatusEvent.HTTP_STATUS,this.handleHTTPStatus);
         this._requests = new Vector.<NRequest>();
         this._cacheDelay = new Timer(16,0);
         this._cacheDelay.addEventListener(TimerEvent.TIMER,this.respondFromCache);
      }
      
      public function clearCache() : void
      {
         this._cache = {};
      }
      
      public function sendRequest(param1:NRequest) : void
      {
         if(param1.cancelsPreviousRequests)
         {
            this.cancelRequests(param1.id);
         }
         if(this._activeRequest)
         {
            if(param1.priority)
            {
               this.queuePriorityRequest(param1);
               return;
            }
            this._requests.push(param1);
            return;
         }
         this._activeRequest = param1;
         this.send();
      }
      
      public function cancelRequests(param1:String) : void
      {
         var _loc2_:int = int(this._requests.length - 1);
         while(_loc2_ >= 0)
         {
            if(this._requests[_loc2_].id == param1)
            {
               this._requests.splice(_loc2_,1);
            }
            _loc2_--;
         }
         if(Boolean(this._activeRequest) && this._activeRequest.id == param1)
         {
            this._ignoreActiveRequest = true;
         }
      }
      
      private function send() : void
      {
         if(this._activeRequest.cachable)
         {
            this.sendCachableRequest();
         }
         else
         {
            this.sendStandardRequest();
         }
      }
      
      private function sendCachableRequest() : void
      {
         var _loc1_:String = this._activeRequest.urlRequest.url + this._activeRequest.urlRequest.data;
         if(this._cache[_loc1_])
         {
            this._cacheDelay.start();
         }
         else
         {
            this.sendStandardRequest();
         }
      }
      
      private function sendStandardRequest() : void
      {
         trace(this._activeRequest.urlRequest.url,this._activeRequest.urlRequest.data);
         this._loader.dataFormat = this._activeRequest.dataFormat;
         this._loader.load(this._activeRequest.urlRequest);
      }
      
      private function queuePriorityRequest(param1:NRequest) : void
      {
         this._requests.unshift(param1);
      }
      
      private function respondFromCache(param1:TimerEvent) : void
      {
         this._cacheDelay.reset();
         var _loc2_:String = this._activeRequest.urlRequest.url + this._activeRequest.urlRequest.data;
         trace("cacheSignature",_loc2_);
         if(this._activeRequest.successEvent)
         {
            dispatch(new NServerEvent(this._activeRequest.successEvent,this._cache[_loc2_],this._activeRequest));
         }
         this.nextRequest();
      }
      
      private function handleRequestComplete(param1:Event) : void
      {
         var responseAsXML:XML = null;
         var in_event:Event = param1;
         trace("Successfully processed request",this._activeRequest.urlRequest.url,this._activeRequest.urlRequest.requestHeaders);
         trace("Response:",this._loader.data);
         if(this._ignoreActiveRequest)
         {
            trace("Ignored. Request was cancelled");
            this._ignoreActiveRequest = false;
            this.nextRequest();
            return;
         }
         try
         {
            responseAsXML = new XML(this._loader.data);
            if(responseAsXML.user.length() != 0)
            {
               this.account.cookie = responseAsXML.user.text();
            }
            if(String(responseAsXML.error.text()) == "TOKEN EXPIRED")
            {
               this._activeRequest.priority = true;
               this.queuePriorityRequest(this._activeRequest);
               dispatch(new NServerEvent(NServerEvent.TOKEN_EXPIRED,null,null));
            }
            else if(this._activeRequest.successEvent)
            {
               dispatch(new NServerEvent(this._activeRequest.successEvent,this._loader.data,this._activeRequest));
            }
         }
         catch(in_error:Error)
         {
            if(_activeRequest.failEvent)
            {
               dispatch(new NServerEvent(_activeRequest.failEvent,_loader.data,_activeRequest));
            }
            else if(_activeRequest.successEvent)
            {
               dispatch(new NServerEvent(_activeRequest.successEvent,_loader.data,_activeRequest));
            }
         }
         if(this._activeRequest.cachable)
         {
            this.cacheActiveRequest();
         }
         this.nextRequest();
      }
      
      private function cacheActiveRequest() : void
      {
         var _loc1_:String = this._activeRequest.urlRequest.url + this._activeRequest.urlRequest.data;
         this._cache[_loc1_] = this._loader.data;
      }
      
      private function handleRequestError(param1:IOErrorEvent) : void
      {
         trace("IOError processing request",this._activeRequest.urlRequest.url,this._activeRequest.urlRequest.requestHeaders,":",param1.text);
         trace("Error message body",this._loader.data);
         if(this._ignoreActiveRequest)
         {
            trace("Ignored. Request was cancelled");
            this._ignoreActiveRequest = false;
         }
         else if(this._activeRequest.failEvent)
         {
            dispatch(new NServerEvent(this._activeRequest.failEvent));
         }
         this.nextRequest();
      }
      
      private function handleHTTPStatus(param1:HTTPStatusEvent) : void
      {
         trace("HTTPStatus",param1.toString());
      }
      
      private function nextRequest() : void
      {
         this._activeRequest = null;
         if(this._requests.length == 0)
         {
            return;
         }
         this._activeRequest = this._requests.pop();
         this.send();
      }
   }
}

