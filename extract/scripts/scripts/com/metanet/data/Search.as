package com.metanet.data
{
   import com.metanet.global.LevelSort;
   
   public class Search
   {
      
      public static const USER_LEVELS:int = 0;
      
      public static const METANET:int = 1;
      
      public static const MY_LEVELS:int = 2;
      
      public static const FAVOURITES:int = 3;
      
      public var details:Vector.<Level>;
      
      public var detailsByID:Object = {};
      
      public var levelsDownloaded:int;
      
      public var finalPage:Boolean;
      
      public var mode:int = -1;
      
      public var offset:int = 0;
      
      public var rowCount:int = 10;
      
      public var sort:String = LevelSort.LEVEL_NAME;
      
      public var terms:Object = {};
      
      public function Search()
      {
         super();
         this.details = new Vector.<Level>();
      }
      
      public function clear() : void
      {
         this.detailsByID = {};
         this.details = new Vector.<Level>();
         this.levelsDownloaded = 0;
         this.sort = LevelSort.LEVEL_NAME;
         this.terms = {};
      }
      
      public function addSearchTerms(param1:String, param2:Array) : void
      {
         this.terms[param1] = param2.join("+");
      }
      
      public function getSearchTerms(param1:String) : String
      {
         return this.terms[param1];
      }
      
      public function clearTerm(param1:String) : void
      {
         this.terms[param1] = null;
      }
      
      public function clearTerms() : void
      {
         this.terms = {};
      }
      
      public function removeLevel(param1:Level) : void
      {
         var _loc2_:int = int(this.details.indexOf(param1));
         if(_loc2_ == -1)
         {
            return;
         }
         this.removeResult(_loc2_);
      }
      
      public function removeResult(param1:int) : void
      {
         var _loc2_:String = this.details[param1].id;
         this.details.splice(param1,1);
      }
      
      public function get isLegal() : Boolean
      {
         var _loc1_:* = undefined;
         if(this.mode == METANET || this.mode == MY_LEVELS)
         {
            return true;
         }
         for each(_loc1_ in this.terms)
         {
            if(_loc1_ != null)
            {
               return true;
            }
         }
         return this.mode == FAVOURITES;
      }
   }
}

