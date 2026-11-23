package com.metanet.ui
{
   public class PlayerKeys
   {
      
      public static const JUMP:uint = 0;
      
      public static const LEFT:uint = 1;
      
      public static const RIGHT:uint = 2;
      
      public static const SUICIDE:uint = 3;
      
      private static const NUMBER_OF_PLAYER_KEYS:uint = 4;
      
      private static const MAX_NUMBER_OF_PLAYERS:uint = 4;
      
      private var _playerBindings:Vector.<int>;
      
      public function PlayerKeys()
      {
         super();
         this._playerBindings = new Vector.<int>(NUMBER_OF_PLAYER_KEYS * MAX_NUMBER_OF_PLAYERS);
         this._playerBindings.fixed = true;
      }
      
      public function bindActionKeyForPlayer(param1:uint, param2:uint, param3:uint) : void
      {
         this._playerBindings[param3 * NUMBER_OF_PLAYER_KEYS + param1] = param2;
      }
      
      public function getActionKeyForPlayer(param1:uint, param2:uint) : int
      {
         return this._playerBindings[param2 * NUMBER_OF_PLAYER_KEYS + param1];
      }
      
      public function getActions(param1:Array) : Vector.<int>
      {
         var _loc4_:int = 0;
         var _loc2_:Vector.<int> = new Vector.<int>();
         var _loc3_:int = 0;
         while(_loc3_ < MAX_NUMBER_OF_PLAYERS)
         {
            _loc4_ = 0;
            while(_loc4_ < param1.length)
            {
               _loc2_[_loc2_.length] = this.getActionKeyForPlayer(param1[_loc4_],_loc3_);
               _loc4_++;
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      public function get keyConfigString() : String
      {
         return this._playerBindings.join(",");
      }
      
      public function set keyConfigString(param1:String) : void
      {
         var _loc2_:Array = param1.split(",");
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_.length)
         {
            this._playerBindings[_loc3_] = _loc2_[_loc3_];
            _loc3_++;
         }
      }
   }
}

