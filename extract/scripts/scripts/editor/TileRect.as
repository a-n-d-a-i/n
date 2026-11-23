package editor
{
   import tiles.tiletypes;
   
   public class TileRect
   {
      
      public var data:Vector.<uint>;
      
      public var stride:uint;
      
      public function TileRect(param1:uint, param2:uint)
      {
         super();
         this.stride = param1;
         this.data = new Vector.<uint>(param1 * param2);
      }
      
      public function GetNumRows() : uint
      {
         var _loc1_:uint = this.data.length / this.stride;
         if(_loc1_ * this.stride != this.data.length)
         {
            trace("WARNING! TileRect.GetNumRows() found an invalid stride/data: " + this.stride + "," + this.data.length);
            return 0;
         }
         return _loc1_;
      }
      
      public function GetDebugString() : String
      {
         var _loc5_:String = null;
         var _loc6_:int = 0;
         var _loc1_:uint = this.stride;
         var _loc2_:uint = this.GetNumRows();
         var _loc3_:* = "TileRect:\n";
         var _loc4_:int = 0;
         while(_loc4_ < _loc2_)
         {
            _loc5_ = "";
            _loc6_ = 0;
            while(_loc6_ < _loc1_)
            {
               _loc5_ += tiletypes.GetDebugCharFromID(this.data[_loc6_ + _loc4_ * _loc1_]);
               _loc6_++;
            }
            _loc3_ += _loc5_;
            _loc3_ += "\n";
            _loc4_++;
         }
         return _loc3_;
      }
   }
}

