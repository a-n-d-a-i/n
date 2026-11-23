package editor
{
   public class EntityBuffer
   {
      
      public var entities:Vector.<Vector.<uint>>;
      
      public var unmatchedCount:uint;
      
      public function EntityBuffer()
      {
         super();
         this.unmatchedCount = 0;
         this.entities = new Vector.<Vector.<uint>>();
      }
      
      public function GetDebugString() : String
      {
         var _loc3_:String = null;
         var _loc4_:* = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc1_:* = "Entity Buffer: " + this.entities.length + " unmatched: " + this.unmatchedCount + "\n";
         var _loc2_:int = 0;
         while(_loc2_ < this.entities.length)
         {
            _loc3_ = _loc2_.toString();
            while(_loc3_.length < 4)
            {
               _loc3_ = "0" + _loc3_;
            }
            _loc4_ = _loc3_ + " : ";
            if(this.entities[_loc2_][0] < 10)
            {
               _loc4_ += "0" + this.entities[_loc2_][0].toString() + " ";
            }
            else
            {
               _loc4_ += this.entities[_loc2_][0].toString() + " ";
            }
            _loc5_ = this.entities[_loc2_][1].toString();
            while(_loc5_.length < 3)
            {
               _loc5_ = "0" + _loc5_;
            }
            _loc6_ = this.entities[_loc2_][2].toString();
            while(_loc6_.length < 3)
            {
               _loc6_ = "0" + _loc6_;
            }
            _loc4_ += _loc5_ + "," + _loc6_ + " ";
            if(this.entities[_loc2_].length > 3)
            {
               _loc4_ += this.entities[_loc2_][3].toString() + " ";
               if(this.entities[_loc2_].length > 4)
               {
                  _loc4_ += this.entities[_loc2_][4].toString() + " ";
               }
            }
            _loc1_ += _loc4_;
            _loc1_ += "\n";
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function WipeUnmatchedEntities() : void
      {
         while(this.unmatchedCount > 0)
         {
            this.entities.pop();
            --this.unmatchedCount;
         }
      }
   }
}

