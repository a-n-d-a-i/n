package tiles
{
   public class tiletypes
   {
      
      public static const EMPTY:int = 0;
      
      public static const FULL:int = 1;
      
      public static const HALF_TOP:int = 2;
      
      public static const HALF_RIGHT:int = 3;
      
      public static const HALF_BOTTOM:int = 4;
      
      public static const HALF_LEFT:int = 5;
      
      public static const MED_PP:int = 6;
      
      public static const MED_NP:int = 7;
      
      public static const MED_NN:int = 8;
      
      public static const MED_PN:int = 9;
      
      public static const CONVEX_PP:int = 10;
      
      public static const CONVEX_NP:int = 11;
      
      public static const CONVEX_NN:int = 12;
      
      public static const CONVEX_PN:int = 13;
      
      public static const CONCAVE_PP:int = 14;
      
      public static const CONCAVE_NP:int = 15;
      
      public static const CONCAVE_NN:int = 16;
      
      public static const CONCAVE_PN:int = 17;
      
      public static const SMALL_22_PP:int = 18;
      
      public static const SMALL_22_NP:int = 19;
      
      public static const SMALL_22_NN:int = 20;
      
      public static const SMALL_22_PN:int = 21;
      
      public static const LARGE_22_PP:int = 22;
      
      public static const LARGE_22_NP:int = 23;
      
      public static const LARGE_22_NN:int = 24;
      
      public static const LARGE_22_PN:int = 25;
      
      public static const SMALL_67_PP:int = 26;
      
      public static const SMALL_67_NP:int = 27;
      
      public static const SMALL_67_NN:int = 28;
      
      public static const SMALL_67_PN:int = 29;
      
      public static const LARGE_67_PP:int = 30;
      
      public static const LARGE_67_NP:int = 31;
      
      public static const LARGE_67_NN:int = 32;
      
      public static const LARGE_67_PN:int = 33;
      
      public static const EDGE_TOP:int = 34;
      
      public static const EDGE_RIGHT:int = 35;
      
      public static const EDGE_BOTTOM:int = 36;
      
      public static const EDGE_LEFT:int = 37;
      
      public static const EDGE_CORNER_UL:int = 38;
      
      public static const EDGE_CORNER_UR:int = 39;
      
      public static const EDGE_CORNER_DL:int = 40;
      
      public static const EDGE_CORNER_DR:int = 41;
      
      public static const num_tile_types:int = 42;
      
      public static const num_ingame_tile_types:int = 34;
      
      private static var MAP_OLD_TYPE_TO_NEW_TYPE:Vector.<int> = new Vector.<int>(num_ingame_tile_types,true);
      
      private static var MAP_NEW_TYPE_TO_CHAR:Vector.<String> = new Vector.<String>(num_ingame_tile_types,true);
      
      private static const hacky_debug_chars:String = ".0123456789ABCDEFGHIJKLMNPQRSTUVWX";
      
      public static var XFORM_INVERT:Vector.<int> = new Vector.<int>(num_ingame_tile_types,true);
      
      public static var XFORM_ROTCW:Vector.<int> = new Vector.<int>(num_ingame_tile_types,true);
      
      public static var XFORM_ROTCCW:Vector.<int> = new Vector.<int>(num_ingame_tile_types,true);
      
      public static var XFORM_FLIPH:Vector.<int> = new Vector.<int>(num_ingame_tile_types,true);
      
      public static var XFORM_FLIPV:Vector.<int> = new Vector.<int>(num_ingame_tile_types,true);
      
      MAP_OLD_TYPE_TO_NEW_TYPE[0] = EMPTY;
      MAP_OLD_TYPE_TO_NEW_TYPE[1] = FULL;
      MAP_OLD_TYPE_TO_NEW_TYPE[2] = MED_PN;
      MAP_OLD_TYPE_TO_NEW_TYPE[3] = MED_NN;
      MAP_OLD_TYPE_TO_NEW_TYPE[4] = MED_NP;
      MAP_OLD_TYPE_TO_NEW_TYPE[5] = MED_PP;
      MAP_OLD_TYPE_TO_NEW_TYPE[6] = CONCAVE_PN;
      MAP_OLD_TYPE_TO_NEW_TYPE[7] = CONCAVE_NN;
      MAP_OLD_TYPE_TO_NEW_TYPE[8] = CONCAVE_NP;
      MAP_OLD_TYPE_TO_NEW_TYPE[9] = CONCAVE_PP;
      MAP_OLD_TYPE_TO_NEW_TYPE[10] = CONVEX_PN;
      MAP_OLD_TYPE_TO_NEW_TYPE[11] = CONVEX_NN;
      MAP_OLD_TYPE_TO_NEW_TYPE[12] = CONVEX_NP;
      MAP_OLD_TYPE_TO_NEW_TYPE[13] = CONVEX_PP;
      MAP_OLD_TYPE_TO_NEW_TYPE[14] = SMALL_22_PN;
      MAP_OLD_TYPE_TO_NEW_TYPE[15] = SMALL_22_NN;
      MAP_OLD_TYPE_TO_NEW_TYPE[16] = SMALL_22_NP;
      MAP_OLD_TYPE_TO_NEW_TYPE[17] = SMALL_22_PP;
      MAP_OLD_TYPE_TO_NEW_TYPE[18] = LARGE_22_PN;
      MAP_OLD_TYPE_TO_NEW_TYPE[19] = LARGE_22_NN;
      MAP_OLD_TYPE_TO_NEW_TYPE[20] = LARGE_22_NP;
      MAP_OLD_TYPE_TO_NEW_TYPE[21] = LARGE_22_PP;
      MAP_OLD_TYPE_TO_NEW_TYPE[22] = SMALL_67_PN;
      MAP_OLD_TYPE_TO_NEW_TYPE[23] = SMALL_67_NN;
      MAP_OLD_TYPE_TO_NEW_TYPE[24] = SMALL_67_NP;
      MAP_OLD_TYPE_TO_NEW_TYPE[25] = SMALL_67_PP;
      MAP_OLD_TYPE_TO_NEW_TYPE[26] = LARGE_67_PN;
      MAP_OLD_TYPE_TO_NEW_TYPE[27] = LARGE_67_NN;
      MAP_OLD_TYPE_TO_NEW_TYPE[28] = LARGE_67_NP;
      MAP_OLD_TYPE_TO_NEW_TYPE[29] = LARGE_67_PP;
      MAP_OLD_TYPE_TO_NEW_TYPE[30] = HALF_BOTTOM;
      MAP_OLD_TYPE_TO_NEW_TYPE[31] = HALF_RIGHT;
      MAP_OLD_TYPE_TO_NEW_TYPE[32] = HALF_TOP;
      MAP_OLD_TYPE_TO_NEW_TYPE[33] = HALF_LEFT;
      XFORM_INVERT[EMPTY] = FULL;
      XFORM_INVERT[FULL] = EMPTY;
      XFORM_INVERT[HALF_TOP] = HALF_BOTTOM;
      XFORM_INVERT[HALF_RIGHT] = HALF_LEFT;
      XFORM_INVERT[HALF_BOTTOM] = HALF_TOP;
      XFORM_INVERT[HALF_LEFT] = HALF_RIGHT;
      XFORM_INVERT[MED_PP] = MED_NN;
      XFORM_INVERT[MED_NP] = MED_PN;
      XFORM_INVERT[MED_NN] = MED_PP;
      XFORM_INVERT[MED_PN] = MED_NP;
      XFORM_INVERT[CONVEX_PP] = CONCAVE_NN;
      XFORM_INVERT[CONVEX_NP] = CONCAVE_PN;
      XFORM_INVERT[CONVEX_NN] = CONCAVE_PP;
      XFORM_INVERT[CONVEX_PN] = CONCAVE_NP;
      XFORM_INVERT[CONCAVE_PP] = CONVEX_NN;
      XFORM_INVERT[CONCAVE_NP] = CONVEX_PN;
      XFORM_INVERT[CONCAVE_NN] = CONVEX_PP;
      XFORM_INVERT[CONCAVE_PN] = CONVEX_NP;
      XFORM_INVERT[SMALL_22_PP] = LARGE_22_NN;
      XFORM_INVERT[SMALL_22_NP] = LARGE_22_PN;
      XFORM_INVERT[SMALL_22_NN] = LARGE_22_PP;
      XFORM_INVERT[SMALL_22_PN] = LARGE_22_NP;
      XFORM_INVERT[LARGE_22_PP] = SMALL_22_NN;
      XFORM_INVERT[LARGE_22_NP] = SMALL_22_PN;
      XFORM_INVERT[LARGE_22_NN] = SMALL_22_PP;
      XFORM_INVERT[LARGE_22_PN] = SMALL_22_NP;
      XFORM_INVERT[SMALL_67_PP] = LARGE_67_NN;
      XFORM_INVERT[SMALL_67_NP] = LARGE_67_PN;
      XFORM_INVERT[SMALL_67_NN] = LARGE_67_PP;
      XFORM_INVERT[SMALL_67_PN] = LARGE_67_NP;
      XFORM_INVERT[LARGE_67_PP] = SMALL_67_NN;
      XFORM_INVERT[LARGE_67_NP] = SMALL_67_PN;
      XFORM_INVERT[LARGE_67_NN] = SMALL_67_PP;
      XFORM_INVERT[LARGE_67_PN] = SMALL_67_NP;
      XFORM_ROTCW[EMPTY] = EMPTY;
      XFORM_ROTCW[FULL] = FULL;
      XFORM_ROTCW[HALF_TOP] = HALF_RIGHT;
      XFORM_ROTCW[HALF_RIGHT] = HALF_BOTTOM;
      XFORM_ROTCW[HALF_BOTTOM] = HALF_LEFT;
      XFORM_ROTCW[HALF_LEFT] = HALF_TOP;
      XFORM_ROTCW[MED_PP] = MED_NP;
      XFORM_ROTCW[MED_NP] = MED_NN;
      XFORM_ROTCW[MED_NN] = MED_PN;
      XFORM_ROTCW[MED_PN] = MED_PP;
      XFORM_ROTCW[CONVEX_PP] = CONVEX_NP;
      XFORM_ROTCW[CONVEX_NP] = CONVEX_NN;
      XFORM_ROTCW[CONVEX_NN] = CONVEX_PN;
      XFORM_ROTCW[CONVEX_PN] = CONVEX_PP;
      XFORM_ROTCW[CONCAVE_PP] = CONCAVE_NP;
      XFORM_ROTCW[CONCAVE_NP] = CONCAVE_NN;
      XFORM_ROTCW[CONCAVE_NN] = CONCAVE_PN;
      XFORM_ROTCW[CONCAVE_PN] = CONCAVE_PP;
      XFORM_ROTCW[SMALL_22_PP] = SMALL_67_NP;
      XFORM_ROTCW[SMALL_22_NP] = SMALL_67_NN;
      XFORM_ROTCW[SMALL_22_NN] = SMALL_67_PN;
      XFORM_ROTCW[SMALL_22_PN] = SMALL_67_PP;
      XFORM_ROTCW[LARGE_22_PP] = LARGE_67_NP;
      XFORM_ROTCW[LARGE_22_NP] = LARGE_67_NN;
      XFORM_ROTCW[LARGE_22_NN] = LARGE_67_PN;
      XFORM_ROTCW[LARGE_22_PN] = LARGE_67_PP;
      XFORM_ROTCW[SMALL_67_PP] = SMALL_22_NP;
      XFORM_ROTCW[SMALL_67_NP] = SMALL_22_NN;
      XFORM_ROTCW[SMALL_67_NN] = SMALL_22_PN;
      XFORM_ROTCW[SMALL_67_PN] = SMALL_22_PP;
      XFORM_ROTCW[LARGE_67_PP] = LARGE_22_NP;
      XFORM_ROTCW[LARGE_67_NP] = LARGE_22_NN;
      XFORM_ROTCW[LARGE_67_NN] = LARGE_22_PN;
      XFORM_ROTCW[LARGE_67_PN] = LARGE_22_PP;
      XFORM_ROTCCW[EMPTY] = EMPTY;
      XFORM_ROTCCW[FULL] = FULL;
      XFORM_ROTCCW[HALF_TOP] = HALF_LEFT;
      XFORM_ROTCCW[HALF_RIGHT] = HALF_TOP;
      XFORM_ROTCCW[HALF_BOTTOM] = HALF_RIGHT;
      XFORM_ROTCCW[HALF_LEFT] = HALF_BOTTOM;
      XFORM_ROTCCW[MED_PP] = MED_PN;
      XFORM_ROTCCW[MED_NP] = MED_PP;
      XFORM_ROTCCW[MED_NN] = MED_NP;
      XFORM_ROTCCW[MED_PN] = MED_NN;
      XFORM_ROTCCW[CONVEX_PP] = CONVEX_PN;
      XFORM_ROTCCW[CONVEX_NP] = CONVEX_PP;
      XFORM_ROTCCW[CONVEX_NN] = CONVEX_NP;
      XFORM_ROTCCW[CONVEX_PN] = CONVEX_NN;
      XFORM_ROTCCW[CONCAVE_PP] = CONCAVE_PN;
      XFORM_ROTCCW[CONCAVE_NP] = CONCAVE_PP;
      XFORM_ROTCCW[CONCAVE_NN] = CONCAVE_NP;
      XFORM_ROTCCW[CONCAVE_PN] = CONCAVE_NN;
      XFORM_ROTCCW[SMALL_22_PP] = SMALL_67_PN;
      XFORM_ROTCCW[SMALL_22_NP] = SMALL_67_PP;
      XFORM_ROTCCW[SMALL_22_NN] = SMALL_67_NP;
      XFORM_ROTCCW[SMALL_22_PN] = SMALL_67_NN;
      XFORM_ROTCCW[LARGE_22_PP] = LARGE_67_PN;
      XFORM_ROTCCW[LARGE_22_NP] = LARGE_67_PP;
      XFORM_ROTCCW[LARGE_22_NN] = LARGE_67_NP;
      XFORM_ROTCCW[LARGE_22_PN] = LARGE_67_NN;
      XFORM_ROTCCW[SMALL_67_PP] = SMALL_22_PN;
      XFORM_ROTCCW[SMALL_67_NP] = SMALL_22_PP;
      XFORM_ROTCCW[SMALL_67_NN] = SMALL_22_NP;
      XFORM_ROTCCW[SMALL_67_PN] = SMALL_22_NN;
      XFORM_ROTCCW[LARGE_67_PP] = LARGE_22_PN;
      XFORM_ROTCCW[LARGE_67_NP] = LARGE_22_PP;
      XFORM_ROTCCW[LARGE_67_NN] = LARGE_22_NP;
      XFORM_ROTCCW[LARGE_67_PN] = LARGE_22_NN;
      XFORM_FLIPH[EMPTY] = EMPTY;
      XFORM_FLIPH[FULL] = FULL;
      XFORM_FLIPH[HALF_TOP] = HALF_TOP;
      XFORM_FLIPH[HALF_RIGHT] = HALF_LEFT;
      XFORM_FLIPH[HALF_BOTTOM] = HALF_BOTTOM;
      XFORM_FLIPH[HALF_LEFT] = HALF_RIGHT;
      XFORM_FLIPH[MED_PP] = MED_NP;
      XFORM_FLIPH[MED_NP] = MED_PP;
      XFORM_FLIPH[MED_NN] = MED_PN;
      XFORM_FLIPH[MED_PN] = MED_NN;
      XFORM_FLIPH[CONVEX_PP] = CONVEX_NP;
      XFORM_FLIPH[CONVEX_NP] = CONVEX_PP;
      XFORM_FLIPH[CONVEX_NN] = CONVEX_PN;
      XFORM_FLIPH[CONVEX_PN] = CONVEX_NN;
      XFORM_FLIPH[CONCAVE_PP] = CONCAVE_NP;
      XFORM_FLIPH[CONCAVE_NP] = CONCAVE_PP;
      XFORM_FLIPH[CONCAVE_NN] = CONCAVE_PN;
      XFORM_FLIPH[CONCAVE_PN] = CONCAVE_NN;
      XFORM_FLIPH[SMALL_22_PP] = SMALL_22_NP;
      XFORM_FLIPH[SMALL_22_NP] = SMALL_22_PP;
      XFORM_FLIPH[SMALL_22_NN] = SMALL_22_PN;
      XFORM_FLIPH[SMALL_22_PN] = SMALL_22_NN;
      XFORM_FLIPH[LARGE_22_PP] = LARGE_22_NP;
      XFORM_FLIPH[LARGE_22_NP] = LARGE_22_PP;
      XFORM_FLIPH[LARGE_22_NN] = LARGE_22_PN;
      XFORM_FLIPH[LARGE_22_PN] = LARGE_22_NN;
      XFORM_FLIPH[SMALL_67_PP] = SMALL_67_NP;
      XFORM_FLIPH[SMALL_67_NP] = SMALL_67_PP;
      XFORM_FLIPH[SMALL_67_NN] = SMALL_67_PN;
      XFORM_FLIPH[SMALL_67_PN] = SMALL_67_NN;
      XFORM_FLIPH[LARGE_67_PP] = LARGE_67_NP;
      XFORM_FLIPH[LARGE_67_NP] = LARGE_67_PP;
      XFORM_FLIPH[LARGE_67_NN] = LARGE_67_PN;
      XFORM_FLIPH[LARGE_67_PN] = LARGE_67_NN;
      XFORM_FLIPV[EMPTY] = EMPTY;
      XFORM_FLIPV[FULL] = FULL;
      XFORM_FLIPV[HALF_TOP] = HALF_BOTTOM;
      XFORM_FLIPV[HALF_RIGHT] = HALF_RIGHT;
      XFORM_FLIPV[HALF_BOTTOM] = HALF_TOP;
      XFORM_FLIPV[HALF_LEFT] = HALF_LEFT;
      XFORM_FLIPV[MED_PP] = MED_PN;
      XFORM_FLIPV[MED_NP] = MED_NN;
      XFORM_FLIPV[MED_NN] = MED_NP;
      XFORM_FLIPV[MED_PN] = MED_PP;
      XFORM_FLIPV[CONVEX_PP] = CONVEX_PN;
      XFORM_FLIPV[CONVEX_NP] = CONVEX_NN;
      XFORM_FLIPV[CONVEX_NN] = CONVEX_NP;
      XFORM_FLIPV[CONVEX_PN] = CONVEX_PP;
      XFORM_FLIPV[CONCAVE_PP] = CONCAVE_PN;
      XFORM_FLIPV[CONCAVE_NP] = CONCAVE_NN;
      XFORM_FLIPV[CONCAVE_NN] = CONCAVE_NP;
      XFORM_FLIPV[CONCAVE_PN] = CONCAVE_PP;
      XFORM_FLIPV[SMALL_22_PP] = SMALL_22_PN;
      XFORM_FLIPV[SMALL_22_NP] = SMALL_22_NN;
      XFORM_FLIPV[SMALL_22_NN] = SMALL_22_NP;
      XFORM_FLIPV[SMALL_22_PN] = SMALL_22_PP;
      XFORM_FLIPV[LARGE_22_PP] = LARGE_22_PN;
      XFORM_FLIPV[LARGE_22_NP] = LARGE_22_NN;
      XFORM_FLIPV[LARGE_22_NN] = LARGE_22_NP;
      XFORM_FLIPV[LARGE_22_PN] = LARGE_22_PP;
      XFORM_FLIPV[SMALL_67_PP] = SMALL_67_PN;
      XFORM_FLIPV[SMALL_67_NP] = SMALL_67_NN;
      XFORM_FLIPV[SMALL_67_NN] = SMALL_67_NP;
      XFORM_FLIPV[SMALL_67_PN] = SMALL_67_PP;
      XFORM_FLIPV[LARGE_67_PP] = LARGE_67_PN;
      XFORM_FLIPV[LARGE_67_NP] = LARGE_67_NN;
      XFORM_FLIPV[LARGE_67_NN] = LARGE_67_NP;
      XFORM_FLIPV[LARGE_67_PN] = LARGE_67_PP;
      
      public function tiletypes()
      {
         super();
      }
      
      public static function GetTypeFromChar(param1:int) : int
      {
         return MAP_OLD_TYPE_TO_NEW_TYPE[param1];
      }
      
      public static function GetDebugCharFromID(param1:int) : String
      {
         return hacky_debug_chars.charAt(param1);
      }
   }
}

