package com.metanet.remote
{
   import flash.net.URLRequest;
   
   public class NRequest
   {
      
      public var id:String;
      
      public var urlRequest:URLRequest;
      
      public var priority:Boolean;
      
      public var cachable:Boolean;
      
      public var cancelsPreviousRequests:Boolean;
      
      public var successEvent:String;
      
      public var failEvent:String;
      
      public var dataFormat:String = "text";
      
      public var referenceLevel:String;
      
      public var referenceUser:int;
      
      public function NRequest(param1:String, param2:URLRequest)
      {
         super();
         this.id = param1;
         this.urlRequest = param2;
      }
   }
}

