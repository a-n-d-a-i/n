package simulation
{
   import flash.utils.ByteArray;
   
   public class sim_globals
   {
      
      public static var HORRIBLY_HACKY_DOES_STRING_TO_BA_ERROR_EXIST:Boolean;
      
      public static var sim_rate:Number = 40;
      
      public static const DEATHTYPE_SUICIDE:int = 0;
      
      public static const DEATHTYPE_FALL:int = 1;
      
      public static const DEATHTYPE_CRUSH:int = 2;
      
      public static const DEATHTYPE_TIME:int = 3;
      
      public static const DEATHTYPE_EXPLOSIVE:int = 4;
      
      public static const DEATHTYPE_LASER:int = 5;
      
      public static const DEATHTYPE_ELECTRIC:int = 6;
      
      public static const DEATHTYPE_BULLET:int = 7;
      
      public static const ENEMYTYPE_SUICIDE:int = 0;
      
      public static const ENEMYTYPE_FALL:int = 1;
      
      public static const ENEMYTYPE_CRUSH:int = 2;
      
      public static const ENEMYTYPE_TIME:int = 3;
      
      public static const ENEMYTYPE_ZAP:int = 4;
      
      public static const ENEMYTYPE_CHAINGUN:int = 5;
      
      public static const ENEMYTYPE_LASER:int = 6;
      
      public static const ENEMYTYPE_TURRET:int = 7;
      
      public static const ENEMYTYPE_ROCKET:int = 8;
      
      public static const ENEMYTYPE_FLOORGUARD:int = 9;
      
      public static const ENEMYTYPE_THWOMP:int = 10;
      
      public static const ENEMYTYPE_MINE:int = 11;
      
      public static const ENEMYTYPE_DEBUG:int = 12;
      
      public static const ETYPE_TO_STRING:Vector.<String> = new Vector.<String>(13,true);
      
      public static const ETYPE_TO_DTYPE:Vector.<int> = new Vector.<int>(13,true);
      
      ETYPE_TO_STRING[ENEMYTYPE_SUICIDE] = "suicide";
      ETYPE_TO_STRING[ENEMYTYPE_FALL] = "falling";
      ETYPE_TO_STRING[ENEMYTYPE_CRUSH] = "crushed";
      ETYPE_TO_STRING[ENEMYTYPE_TIME] = "out of time";
      ETYPE_TO_STRING[ENEMYTYPE_ZAP] = "zap";
      ETYPE_TO_STRING[ENEMYTYPE_CHAINGUN] = "chaingun";
      ETYPE_TO_STRING[ENEMYTYPE_LASER] = "laser";
      ETYPE_TO_STRING[ENEMYTYPE_TURRET] = "turret";
      ETYPE_TO_STRING[ENEMYTYPE_ROCKET] = "rocket";
      ETYPE_TO_STRING[ENEMYTYPE_FLOORGUARD] = "floorguard";
      ETYPE_TO_STRING[ENEMYTYPE_THWOMP] = "thwomp";
      ETYPE_TO_STRING[ENEMYTYPE_MINE] = "mine";
      ETYPE_TO_STRING[ENEMYTYPE_DEBUG] = "debug";
      ETYPE_TO_DTYPE[ENEMYTYPE_SUICIDE] = DEATHTYPE_EXPLOSIVE;
      ETYPE_TO_DTYPE[ENEMYTYPE_FALL] = DEATHTYPE_FALL;
      ETYPE_TO_DTYPE[ENEMYTYPE_CRUSH] = DEATHTYPE_CRUSH;
      ETYPE_TO_DTYPE[ENEMYTYPE_TIME] = DEATHTYPE_EXPLOSIVE;
      ETYPE_TO_DTYPE[ENEMYTYPE_ROCKET] = DEATHTYPE_EXPLOSIVE;
      ETYPE_TO_DTYPE[ENEMYTYPE_MINE] = DEATHTYPE_EXPLOSIVE;
      ETYPE_TO_DTYPE[ENEMYTYPE_LASER] = DEATHTYPE_LASER;
      ETYPE_TO_DTYPE[ENEMYTYPE_ZAP] = DEATHTYPE_ELECTRIC;
      ETYPE_TO_DTYPE[ENEMYTYPE_FLOORGUARD] = DEATHTYPE_ELECTRIC;
      ETYPE_TO_DTYPE[ENEMYTYPE_THWOMP] = DEATHTYPE_ELECTRIC;
      ETYPE_TO_DTYPE[ENEMYTYPE_CHAINGUN] = DEATHTYPE_BULLET;
      ETYPE_TO_DTYPE[ENEMYTYPE_TURRET] = DEATHTYPE_BULLET;
      ETYPE_TO_DTYPE[ENEMYTYPE_DEBUG] = DEATHTYPE_BULLET;
      
      public function sim_globals()
      {
         super();
      }
      
      public static function BAtoString(param1:ByteArray) : String
      {
         var _loc3_:uint = 0;
         if(param1 == null)
         {
            return "";
         }
         var _loc2_:String = "";
         param1.position = 0;
         while(param1.bytesAvailable)
         {
            _loc3_ = uint(param1.readByte());
            _loc2_ += ["0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f"][_loc3_ % 16];
            _loc3_ >>= 4;
            _loc2_ += ["0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f"][_loc3_ % 16];
         }
         param1.position = 0;
         return _loc2_;
      }
      
      public static function StringtoBA(param1:String) : ByteArray
      {
         var _loc4_:uint = 0;
         HORRIBLY_HACKY_DOES_STRING_TO_BA_ERROR_EXIST = false;
         var _loc2_:ByteArray = new ByteArray();
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            _loc4_ = uint(BAS_hint(param1.charAt(_loc3_)) + (BAS_hint(param1.charAt(_loc3_ + 1)) << 4));
            _loc2_.writeByte(_loc4_);
            _loc3_ += 2;
         }
         _loc2_.position = 0;
         return _loc2_;
      }
      
      private static function BAS_hint(param1:String) : uint
      {
         switch(param1)
         {
            case "0":
               return 0;
            case "1":
               return 1;
            case "2":
               return 2;
            case "3":
               return 3;
            case "4":
               return 4;
            case "5":
               return 5;
            case "6":
               return 6;
            case "7":
               return 7;
            case "8":
               return 8;
            case "9":
               return 9;
            case "a":
               return 10;
            case "b":
               return 11;
            case "c":
               return 12;
            case "d":
               return 13;
            case "e":
               return 14;
            case "f":
               return 15;
            default:
               trace("invalid character");
               HORRIBLY_HACKY_DOES_STRING_TO_BA_ERROR_EXIST = true;
               return 16;
         }
      }
   }
}

