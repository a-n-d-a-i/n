package tiles
{
   public class edgedefs
   {
      
      private static const edgestates_X:Vector.<int> = new Vector.<int>(tiletypes.num_tile_types * 6,true);
      
      private static const edgestates_Y:Vector.<int> = new Vector.<int>(tiletypes.num_tile_types * 6,true);
      
      HELPER_SetEdgeStates_X(tiletypes.FULL,2,0,2,2,0,2);
      HELPER_SetEdgeStates_Y(tiletypes.FULL,2,0,2,2,0,2);
      HELPER_SetEdgeStates_Y(tiletypes.EDGE_BOTTOM,0,0,2,0,0,2);
      HELPER_SetEdgeStates_Rotate90(tiletypes.EDGE_BOTTOM,tiletypes.EDGE_LEFT);
      HELPER_SetEdgeStates_Rotate180(tiletypes.EDGE_BOTTOM,tiletypes.EDGE_TOP);
      HELPER_SetEdgeStates_Rotate270(tiletypes.EDGE_BOTTOM,tiletypes.EDGE_RIGHT);
      HELPER_SetEdgeStates_X(tiletypes.HALF_BOTTOM,0,0,0,2,0,2);
      HELPER_SetEdgeStates_Y(tiletypes.HALF_BOTTOM,0,2,2,0,2,2);
      HELPER_SetEdgeStates_Rotate90(tiletypes.HALF_BOTTOM,tiletypes.HALF_LEFT);
      HELPER_SetEdgeStates_Rotate180(tiletypes.HALF_BOTTOM,tiletypes.HALF_TOP);
      HELPER_SetEdgeStates_Rotate270(tiletypes.HALF_BOTTOM,tiletypes.HALF_RIGHT);
      HELPER_SetEdgeStates_X(tiletypes.CONCAVE_PP,2,0,1,2,1,0);
      HELPER_SetEdgeStates_Y(tiletypes.CONCAVE_PP,2,0,1,2,1,0);
      HELPER_SetEdgeStates_Rotate90(tiletypes.CONCAVE_PP,tiletypes.CONCAVE_NP);
      HELPER_SetEdgeStates_Rotate180(tiletypes.CONCAVE_PP,tiletypes.CONCAVE_NN);
      HELPER_SetEdgeStates_Rotate270(tiletypes.CONCAVE_PP,tiletypes.CONCAVE_PN);
      HELPER_SetEdgeStates_X(tiletypes.CONVEX_PP,2,0,1,2,0,1);
      HELPER_SetEdgeStates_Y(tiletypes.CONVEX_PP,2,0,1,2,0,1);
      HELPER_SetEdgeStates_Rotate90(tiletypes.CONVEX_PP,tiletypes.CONVEX_NP);
      HELPER_SetEdgeStates_Rotate180(tiletypes.CONVEX_PP,tiletypes.CONVEX_NN);
      HELPER_SetEdgeStates_Rotate270(tiletypes.CONVEX_PP,tiletypes.CONVEX_PN);
      HELPER_SetEdgeStates_Copy(tiletypes.CONCAVE_PP,tiletypes.MED_PP);
      HELPER_SetEdgeStates_Copy(tiletypes.CONCAVE_NP,tiletypes.MED_NP);
      HELPER_SetEdgeStates_Copy(tiletypes.CONCAVE_NN,tiletypes.MED_NN);
      HELPER_SetEdgeStates_Copy(tiletypes.CONCAVE_PN,tiletypes.MED_PN);
      HELPER_SetEdgeStates_X(tiletypes.SMALL_22_PP,2,0,1,0,0,0);
      HELPER_SetEdgeStates_Y(tiletypes.SMALL_22_PP,2,1,0,2,1,0);
      HELPER_SetEdgeStates_Rotate90(tiletypes.SMALL_22_PP,tiletypes.SMALL_67_NP);
      HELPER_SetEdgeStates_Rotate180(tiletypes.SMALL_22_PP,tiletypes.SMALL_22_NN);
      HELPER_SetEdgeStates_Rotate270(tiletypes.SMALL_22_PP,tiletypes.SMALL_67_PN);
      HELPER_SetEdgeStates_X(tiletypes.SMALL_67_PP,2,1,0,2,1,0);
      HELPER_SetEdgeStates_Y(tiletypes.SMALL_67_PP,2,0,1,0,0,0);
      HELPER_SetEdgeStates_Rotate90(tiletypes.SMALL_67_PP,tiletypes.SMALL_22_NP);
      HELPER_SetEdgeStates_Rotate180(tiletypes.SMALL_67_PP,tiletypes.SMALL_67_NN);
      HELPER_SetEdgeStates_Rotate270(tiletypes.SMALL_67_PP,tiletypes.SMALL_22_PN);
      HELPER_SetEdgeStates_X(tiletypes.LARGE_22_PP,2,0,2,2,0,1);
      HELPER_SetEdgeStates_Y(tiletypes.LARGE_22_PP,2,0,1,2,0,1);
      HELPER_SetEdgeStates_Rotate90(tiletypes.LARGE_22_PP,tiletypes.LARGE_67_NP);
      HELPER_SetEdgeStates_Rotate180(tiletypes.LARGE_22_PP,tiletypes.LARGE_22_NN);
      HELPER_SetEdgeStates_Rotate270(tiletypes.LARGE_22_PP,tiletypes.LARGE_67_PN);
      HELPER_SetEdgeStates_X(tiletypes.LARGE_67_PP,2,0,1,2,0,1);
      HELPER_SetEdgeStates_Y(tiletypes.LARGE_67_PP,2,0,2,2,0,1);
      HELPER_SetEdgeStates_Rotate90(tiletypes.LARGE_67_PP,tiletypes.LARGE_22_NP);
      HELPER_SetEdgeStates_Rotate180(tiletypes.LARGE_67_PP,tiletypes.LARGE_67_NN);
      HELPER_SetEdgeStates_Rotate270(tiletypes.LARGE_67_PP,tiletypes.LARGE_22_PN);
      
      public function edgedefs()
      {
         super();
      }
      
      public static function GetEdgeState_X(param1:int, param2:int) : int
      {
         return edgestates_X[param1 * 6 + param2];
      }
      
      public static function GetEdgeState_Y(param1:int, param2:int) : int
      {
         return edgestates_Y[param1 * 6 + param2];
      }
      
      private static function HELPER_SetEdgeStates_X(param1:int, param2:int, param3:int, param4:int, param5:int, param6:int, param7:int) : void
      {
         var _loc8_:int = param1 * 6;
         edgestates_X[_loc8_ + 0] = param2;
         edgestates_X[_loc8_ + 1] = param3;
         edgestates_X[_loc8_ + 2] = param4;
         edgestates_X[_loc8_ + 3] = param5;
         edgestates_X[_loc8_ + 4] = param6;
         edgestates_X[_loc8_ + 5] = param7;
      }
      
      private static function HELPER_SetEdgeStates_Y(param1:int, param2:int, param3:int, param4:int, param5:int, param6:int, param7:int) : void
      {
         var _loc8_:int = param1 * 6;
         edgestates_Y[_loc8_ + 0] = param2;
         edgestates_Y[_loc8_ + 1] = param3;
         edgestates_Y[_loc8_ + 2] = param4;
         edgestates_Y[_loc8_ + 3] = param5;
         edgestates_Y[_loc8_ + 4] = param6;
         edgestates_Y[_loc8_ + 5] = param7;
      }
      
      private static function HELPER_SetEdgeStates_Copy(param1:int, param2:int) : void
      {
         var _loc3_:int = param1 * 6;
         var _loc4_:int = param2 * 6;
         edgestates_X[_loc4_ + 0] = edgestates_X[_loc3_ + 0];
         edgestates_X[_loc4_ + 1] = edgestates_X[_loc3_ + 1];
         edgestates_X[_loc4_ + 2] = edgestates_X[_loc3_ + 2];
         edgestates_X[_loc4_ + 3] = edgestates_X[_loc3_ + 3];
         edgestates_X[_loc4_ + 4] = edgestates_X[_loc3_ + 4];
         edgestates_X[_loc4_ + 5] = edgestates_X[_loc3_ + 5];
         edgestates_Y[_loc4_ + 0] = edgestates_Y[_loc3_ + 0];
         edgestates_Y[_loc4_ + 1] = edgestates_Y[_loc3_ + 1];
         edgestates_Y[_loc4_ + 2] = edgestates_Y[_loc3_ + 2];
         edgestates_Y[_loc4_ + 3] = edgestates_Y[_loc3_ + 3];
         edgestates_Y[_loc4_ + 4] = edgestates_Y[_loc3_ + 4];
         edgestates_Y[_loc4_ + 5] = edgestates_Y[_loc3_ + 5];
      }
      
      private static function HELPER_SetEdgeStates_Rotate90(param1:int, param2:int) : void
      {
         var _loc3_:int = param1 * 6;
         var _loc4_:int = param2 * 6;
         edgestates_Y[_loc4_ + 0] = edgestates_X[_loc3_ + 3];
         edgestates_Y[_loc4_ + 1] = edgestates_X[_loc3_ + 4];
         edgestates_Y[_loc4_ + 2] = edgestates_X[_loc3_ + 5];
         edgestates_Y[_loc4_ + 3] = edgestates_X[_loc3_ + 0];
         edgestates_Y[_loc4_ + 4] = edgestates_X[_loc3_ + 1];
         edgestates_Y[_loc4_ + 5] = edgestates_X[_loc3_ + 2];
         edgestates_X[_loc4_ + 0] = edgestates_Y[_loc3_ + 2];
         edgestates_X[_loc4_ + 1] = edgestates_Y[_loc3_ + 1];
         edgestates_X[_loc4_ + 2] = edgestates_Y[_loc3_ + 0];
         edgestates_X[_loc4_ + 3] = edgestates_Y[_loc3_ + 5];
         edgestates_X[_loc4_ + 4] = edgestates_Y[_loc3_ + 4];
         edgestates_X[_loc4_ + 5] = edgestates_Y[_loc3_ + 3];
      }
      
      private static function HELPER_SetEdgeStates_Rotate180(param1:int, param2:int) : void
      {
         var _loc3_:int = param1 * 6;
         var _loc4_:int = param2 * 6;
         edgestates_X[_loc4_ + 0] = edgestates_X[_loc3_ + 5];
         edgestates_X[_loc4_ + 1] = edgestates_X[_loc3_ + 4];
         edgestates_X[_loc4_ + 2] = edgestates_X[_loc3_ + 3];
         edgestates_X[_loc4_ + 3] = edgestates_X[_loc3_ + 2];
         edgestates_X[_loc4_ + 4] = edgestates_X[_loc3_ + 1];
         edgestates_X[_loc4_ + 5] = edgestates_X[_loc3_ + 0];
         edgestates_Y[_loc4_ + 0] = edgestates_Y[_loc3_ + 5];
         edgestates_Y[_loc4_ + 1] = edgestates_Y[_loc3_ + 4];
         edgestates_Y[_loc4_ + 2] = edgestates_Y[_loc3_ + 3];
         edgestates_Y[_loc4_ + 3] = edgestates_Y[_loc3_ + 2];
         edgestates_Y[_loc4_ + 4] = edgestates_Y[_loc3_ + 1];
         edgestates_Y[_loc4_ + 5] = edgestates_Y[_loc3_ + 0];
      }
      
      private static function HELPER_SetEdgeStates_Rotate270(param1:int, param2:int) : void
      {
         var _loc3_:int = param1 * 6;
         var _loc4_:int = param2 * 6;
         edgestates_Y[_loc4_ + 0] = edgestates_X[_loc3_ + 2];
         edgestates_Y[_loc4_ + 1] = edgestates_X[_loc3_ + 1];
         edgestates_Y[_loc4_ + 2] = edgestates_X[_loc3_ + 0];
         edgestates_Y[_loc4_ + 3] = edgestates_X[_loc3_ + 5];
         edgestates_Y[_loc4_ + 4] = edgestates_X[_loc3_ + 4];
         edgestates_Y[_loc4_ + 5] = edgestates_X[_loc3_ + 3];
         edgestates_X[_loc4_ + 0] = edgestates_Y[_loc3_ + 3];
         edgestates_X[_loc4_ + 1] = edgestates_Y[_loc3_ + 4];
         edgestates_X[_loc4_ + 2] = edgestates_Y[_loc3_ + 5];
         edgestates_X[_loc4_ + 3] = edgestates_Y[_loc3_ + 0];
         edgestates_X[_loc4_ + 4] = edgestates_Y[_loc3_ + 1];
         edgestates_X[_loc4_ + 5] = edgestates_Y[_loc3_ + 2];
      }
   }
}

