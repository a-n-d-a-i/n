package com.metanet.data
{
   import flash.utils.ByteArray;
   
   public class Level
   {
      
      public var id:String;
      
      public var name:String = "Untitled";
      
      public var creatorName:String;
      
      public var creatorID:String;
      
      public var meanRating:Number;
      
      public var loaded:Boolean;
      
      public var personalBest:int;
      
      public var minimumHighscore:int;
      
      public var favourite:Boolean;
      
      public var data:ByteArray;
      
      public var isNew:Boolean = false;
      
      public var published:Boolean;
      
      public var personalRating:int;
      
      public var fullData:Boolean = false;
      
      public var waitingForUpload:Boolean;
      
      public function Level()
      {
         super();
      }
      
      public function get isMetanetLevel() : Boolean
      {
         return Number(this.id) < 1000;
      }
   }
}

