package com.metanet.remote
{
   import com.foxarc.util.Base64;
   import flash.utils.ByteArray;
   
   public class MultiPartVariable
   {
      
      public var filename:String;
      
      public var contentType:String;
      
      private var _key:String;
      
      private var _value:*;
      
      private var NEWLINE:String;
      
      public function MultiPartVariable(param1:String, param2:*)
      {
         super();
         this.NEWLINE = String.fromCharCode(13,10);
         this._key = param1;
         this._value = param2;
      }
      
      public function compose() : String
      {
         var _loc1_:* = "Content-Disposition: form-data; name=" + this.quoted(this._key);
         if(this.filename)
         {
            _loc1_ += "; filename=";
            _loc1_ += this.quoted(this.filename) + this.NEWLINE;
         }
         else
         {
            _loc1_ += this.NEWLINE;
         }
         if(this.contentType)
         {
            _loc1_ += "Content-Type: ";
            _loc1_ += this.contentType + this.NEWLINE;
         }
         _loc1_ += this.NEWLINE;
         return _loc1_ + (this.valueEncoded() + this.NEWLINE);
      }
      
      private function valueEncoded() : String
      {
         if(this._value is ByteArray)
         {
            this._value.compress();
            return Base64.encode(this._value);
         }
         return this._value.toString();
      }
      
      private function quoted(param1:String) : String
      {
         return "\"" + param1 + "\"";
      }
   }
}

