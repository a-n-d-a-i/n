package com.metanet.remote
{
   import flash.net.URLRequest;
   import flash.net.URLRequestHeader;
   import flash.net.URLRequestMethod;
   
   public class MultiPartRequest
   {
      
      public var boundary:String;
      
      private var _url:String;
      
      private var _parts:Vector.<MultiPartVariable>;
      
      private var NEWLINE:String;
      
      public function MultiPartRequest(param1:String)
      {
         super();
         this.NEWLINE = String.fromCharCode(13,10);
         this._url = param1;
         this._parts = new Vector.<MultiPartVariable>();
      }
      
      public function add(param1:MultiPartVariable) : void
      {
         this._parts[this._parts.length] = param1;
      }
      
      public function compose() : URLRequest
      {
         var _loc1_:URLRequest = new URLRequest(this._url);
         _loc1_.method = URLRequestMethod.POST;
         var _loc2_:String = this.NEWLINE;
         var _loc3_:int = 0;
         while(_loc3_ < this._parts.length)
         {
            _loc2_ += "--" + this.boundary + this.NEWLINE;
            _loc2_ += this._parts[_loc3_].compose();
            _loc3_++;
         }
         _loc2_ += "--" + this.boundary + "--";
         _loc1_.data = _loc2_;
         _loc1_.requestHeaders.push(new URLRequestHeader("Content-Type","multipart/form-data; boundary=" + this.boundary));
         return _loc1_;
      }
   }
}

