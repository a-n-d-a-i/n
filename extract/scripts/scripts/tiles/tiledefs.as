package tiles
{
   import simulation.collision.Segment;
   
   public class tiledefs
   {
      
      private static const segdefs:Vector.<TileEdgeArchetype> = new Vector.<TileEdgeArchetype>(tiletypes.num_tile_types,true);
      
      private static var perpindex:Vector.<uint> = new Vector.<uint>(8,true);
      
      private static const boundaryflags:Vector.<Vector.<Boolean>> = new Vector.<Vector.<Boolean>>(tiletypes.num_tile_types,true);
      
      private static const boundarydefs:Vector.<TileEdgeArchetype> = new Vector.<TileEdgeArchetype>(12,true);
      
      segdefs[tiletypes.EMPTY] = null;
      segdefs[tiletypes.FULL] = null;
      segdefs[tiletypes.EDGE_TOP] = null;
      segdefs[tiletypes.EDGE_RIGHT] = null;
      segdefs[tiletypes.EDGE_BOTTOM] = null;
      segdefs[tiletypes.EDGE_LEFT] = null;
      segdefs[tiletypes.EDGE_CORNER_UL] = null;
      segdefs[tiletypes.EDGE_CORNER_UR] = null;
      segdefs[tiletypes.EDGE_CORNER_DL] = null;
      segdefs[tiletypes.EDGE_CORNER_DR] = null;
      segdefs[tiletypes.HALF_TOP] = new TileEdgeArchetype_Linear(-1,0,1,0);
      segdefs[tiletypes.HALF_RIGHT] = segdefs[tiletypes.HALF_TOP].GeneratePerpArchetype();
      segdefs[tiletypes.HALF_BOTTOM] = segdefs[tiletypes.HALF_RIGHT].GeneratePerpArchetype();
      segdefs[tiletypes.HALF_LEFT] = segdefs[tiletypes.HALF_BOTTOM].GeneratePerpArchetype();
      segdefs[tiletypes.MED_PP] = new TileEdgeArchetype_Linear(-1,1,1,-1);
      segdefs[tiletypes.MED_NP] = segdefs[tiletypes.MED_PP].GeneratePerpArchetype();
      segdefs[tiletypes.MED_NN] = segdefs[tiletypes.MED_NP].GeneratePerpArchetype();
      segdefs[tiletypes.MED_PN] = segdefs[tiletypes.MED_NN].GeneratePerpArchetype();
      segdefs[tiletypes.CONVEX_PP] = new TileEdgeArchetype_Circular(-1,1,1,-1,-1,-1);
      segdefs[tiletypes.CONVEX_NP] = segdefs[tiletypes.CONVEX_PP].GeneratePerpArchetype();
      segdefs[tiletypes.CONVEX_NN] = segdefs[tiletypes.CONVEX_NP].GeneratePerpArchetype();
      segdefs[tiletypes.CONVEX_PN] = segdefs[tiletypes.CONVEX_NN].GeneratePerpArchetype();
      segdefs[tiletypes.CONCAVE_PP] = new TileEdgeArchetype_Circular(-1,1,1,-1,1,1);
      segdefs[tiletypes.CONCAVE_NP] = segdefs[tiletypes.CONCAVE_PP].GeneratePerpArchetype();
      segdefs[tiletypes.CONCAVE_NN] = segdefs[tiletypes.CONCAVE_NP].GeneratePerpArchetype();
      segdefs[tiletypes.CONCAVE_PN] = segdefs[tiletypes.CONCAVE_NN].GeneratePerpArchetype();
      segdefs[tiletypes.SMALL_22_PP] = new TileEdgeArchetype_Linear(-1,0,1,-1);
      segdefs[tiletypes.SMALL_67_NP] = segdefs[tiletypes.SMALL_22_PP].GeneratePerpArchetype();
      segdefs[tiletypes.SMALL_22_NN] = segdefs[tiletypes.SMALL_67_NP].GeneratePerpArchetype();
      segdefs[tiletypes.SMALL_67_PN] = segdefs[tiletypes.SMALL_22_NN].GeneratePerpArchetype();
      segdefs[tiletypes.SMALL_67_PP] = new TileEdgeArchetype_Linear(-1,1,0,-1);
      segdefs[tiletypes.SMALL_22_NP] = segdefs[tiletypes.SMALL_67_PP].GeneratePerpArchetype();
      segdefs[tiletypes.SMALL_67_NN] = segdefs[tiletypes.SMALL_22_NP].GeneratePerpArchetype();
      segdefs[tiletypes.SMALL_22_PN] = segdefs[tiletypes.SMALL_67_NN].GeneratePerpArchetype();
      segdefs[tiletypes.LARGE_22_PP] = new TileEdgeArchetype_Linear(-1,1,1,0);
      segdefs[tiletypes.LARGE_67_NP] = segdefs[tiletypes.LARGE_22_PP].GeneratePerpArchetype();
      segdefs[tiletypes.LARGE_22_NN] = segdefs[tiletypes.LARGE_67_NP].GeneratePerpArchetype();
      segdefs[tiletypes.LARGE_67_PN] = segdefs[tiletypes.LARGE_22_NN].GeneratePerpArchetype();
      segdefs[tiletypes.LARGE_67_PP] = new TileEdgeArchetype_Linear(0,1,1,-1);
      segdefs[tiletypes.LARGE_22_NP] = segdefs[tiletypes.LARGE_67_PP].GeneratePerpArchetype();
      segdefs[tiletypes.LARGE_67_NN] = segdefs[tiletypes.LARGE_22_NP].GeneratePerpArchetype();
      segdefs[tiletypes.LARGE_22_PN] = segdefs[tiletypes.LARGE_67_NN].GeneratePerpArchetype();
      perpindex[0] = 2;
      perpindex[1] = 3;
      perpindex[2] = 5;
      perpindex[3] = 4;
      perpindex[4] = 6;
      perpindex[5] = 7;
      perpindex[6] = 1;
      perpindex[7] = 0;
      HELPER_InitBoundaryFlags();
      boundaryflags[tiletypes.FULL][0] = true;
      boundaryflags[tiletypes.FULL][1] = true;
      boundaryflags[tiletypes.FULL][2] = true;
      boundaryflags[tiletypes.FULL][3] = true;
      boundaryflags[tiletypes.FULL][4] = true;
      boundaryflags[tiletypes.FULL][5] = true;
      boundaryflags[tiletypes.FULL][6] = true;
      boundaryflags[tiletypes.FULL][7] = true;
      boundaryflags[tiletypes.EDGE_TOP][6] = true;
      boundaryflags[tiletypes.EDGE_TOP][7] = true;
      HELPER_SetBoundaryFlags_Perp(tiletypes.EDGE_TOP,tiletypes.EDGE_RIGHT);
      HELPER_SetBoundaryFlags_Perp(tiletypes.EDGE_RIGHT,tiletypes.EDGE_BOTTOM);
      HELPER_SetBoundaryFlags_Perp(tiletypes.EDGE_BOTTOM,tiletypes.EDGE_LEFT);
      boundaryflags[tiletypes.HALF_TOP][0] = true;
      boundaryflags[tiletypes.HALF_TOP][4] = true;
      boundaryflags[tiletypes.HALF_TOP][6] = true;
      boundaryflags[tiletypes.HALF_TOP][7] = true;
      HELPER_SetBoundaryFlags_Perp(tiletypes.HALF_TOP,tiletypes.HALF_RIGHT);
      HELPER_SetBoundaryFlags_Perp(tiletypes.HALF_RIGHT,tiletypes.HALF_BOTTOM);
      HELPER_SetBoundaryFlags_Perp(tiletypes.HALF_BOTTOM,tiletypes.HALF_LEFT);
      boundaryflags[tiletypes.MED_PP][0] = true;
      boundaryflags[tiletypes.MED_PP][1] = true;
      boundaryflags[tiletypes.MED_PP][6] = true;
      boundaryflags[tiletypes.MED_PP][7] = true;
      HELPER_SetBoundaryFlags_Perp(tiletypes.MED_PP,tiletypes.MED_NP);
      HELPER_SetBoundaryFlags_Perp(tiletypes.MED_NP,tiletypes.MED_NN);
      HELPER_SetBoundaryFlags_Perp(tiletypes.MED_NN,tiletypes.MED_PN);
      HELPER_SetBoundaryFlags_Copy(tiletypes.MED_PP,tiletypes.CONVEX_PP);
      HELPER_SetBoundaryFlags_Copy(tiletypes.MED_NP,tiletypes.CONVEX_NP);
      HELPER_SetBoundaryFlags_Copy(tiletypes.MED_NN,tiletypes.CONVEX_NN);
      HELPER_SetBoundaryFlags_Copy(tiletypes.MED_PN,tiletypes.CONVEX_PN);
      HELPER_SetBoundaryFlags_Copy(tiletypes.MED_PP,tiletypes.CONCAVE_PP);
      HELPER_SetBoundaryFlags_Copy(tiletypes.MED_NP,tiletypes.CONCAVE_NP);
      HELPER_SetBoundaryFlags_Copy(tiletypes.MED_NN,tiletypes.CONCAVE_NN);
      HELPER_SetBoundaryFlags_Copy(tiletypes.MED_PN,tiletypes.CONCAVE_PN);
      boundaryflags[tiletypes.SMALL_22_PP][0] = true;
      boundaryflags[tiletypes.SMALL_22_PP][6] = true;
      boundaryflags[tiletypes.SMALL_22_PP][7] = true;
      HELPER_SetBoundaryFlags_Perp(tiletypes.SMALL_22_PP,tiletypes.SMALL_67_NP);
      HELPER_SetBoundaryFlags_Perp(tiletypes.SMALL_67_NP,tiletypes.SMALL_22_NN);
      HELPER_SetBoundaryFlags_Perp(tiletypes.SMALL_22_NN,tiletypes.SMALL_67_PN);
      boundaryflags[tiletypes.SMALL_67_PP][0] = true;
      boundaryflags[tiletypes.SMALL_67_PP][1] = true;
      boundaryflags[tiletypes.SMALL_67_PP][6] = true;
      HELPER_SetBoundaryFlags_Perp(tiletypes.SMALL_67_PP,tiletypes.SMALL_22_NP);
      HELPER_SetBoundaryFlags_Perp(tiletypes.SMALL_22_NP,tiletypes.SMALL_67_NN);
      HELPER_SetBoundaryFlags_Perp(tiletypes.SMALL_67_NN,tiletypes.SMALL_22_PN);
      boundaryflags[tiletypes.LARGE_22_PP][0] = true;
      boundaryflags[tiletypes.LARGE_22_PP][1] = true;
      boundaryflags[tiletypes.LARGE_22_PP][4] = true;
      boundaryflags[tiletypes.LARGE_22_PP][6] = true;
      boundaryflags[tiletypes.LARGE_22_PP][7] = true;
      HELPER_SetBoundaryFlags_Perp(tiletypes.LARGE_22_PP,tiletypes.LARGE_67_NP);
      HELPER_SetBoundaryFlags_Perp(tiletypes.LARGE_67_NP,tiletypes.LARGE_22_NN);
      HELPER_SetBoundaryFlags_Perp(tiletypes.LARGE_22_NN,tiletypes.LARGE_67_PN);
      boundaryflags[tiletypes.LARGE_67_PP][0] = true;
      boundaryflags[tiletypes.LARGE_67_PP][1] = true;
      boundaryflags[tiletypes.LARGE_67_PP][2] = true;
      boundaryflags[tiletypes.LARGE_67_PP][6] = true;
      boundaryflags[tiletypes.LARGE_67_PP][7] = true;
      HELPER_SetBoundaryFlags_Perp(tiletypes.LARGE_67_PP,tiletypes.LARGE_22_NP);
      HELPER_SetBoundaryFlags_Perp(tiletypes.LARGE_22_NP,tiletypes.LARGE_67_NN);
      HELPER_SetBoundaryFlags_Perp(tiletypes.LARGE_67_NN,tiletypes.LARGE_22_PN);
      boundarydefs[0] = new TileEdgeArchetype_Linear(-1,-1,-1,0);
      boundarydefs[1] = new TileEdgeArchetype_Linear(-1,0,-1,1);
      boundarydefs[2] = new TileEdgeArchetype_Linear(-1,-1,-1,1);
      boundarydefs[9] = boundarydefs[1].GeneratePerpArchetype();
      boundarydefs[10] = boundarydefs[0].GeneratePerpArchetype();
      boundarydefs[11] = boundarydefs[2].GeneratePerpArchetype();
      boundarydefs[7] = boundarydefs[10].GeneratePerpArchetype();
      boundarydefs[6] = boundarydefs[9].GeneratePerpArchetype();
      boundarydefs[8] = boundarydefs[11].GeneratePerpArchetype();
      boundarydefs[4] = boundarydefs[6].GeneratePerpArchetype();
      boundarydefs[3] = boundarydefs[7].GeneratePerpArchetype();
      boundarydefs[5] = boundarydefs[8].GeneratePerpArchetype();
      
      public function tiledefs()
      {
         super();
      }
      
      public static function GenerateTileSegments_Filtered(param1:int, param2:Vector.<int>, param3:Number, param4:Number, param5:Number) : Vector.<Segment>
      {
         var _loc9_:Boolean = false;
         var _loc10_:Boolean = false;
         if(param1 < 0 || param1 >= tiletypes.num_tile_types)
         {
            trace("WARNING! GenerateTileSegments() was passed an invalid tiletype: " + param1);
            return null;
         }
         var _loc6_:Vector.<Segment> = new Vector.<Segment>();
         var _loc7_:int = 0;
         while(_loc7_ < 4)
         {
            _loc9_ = boundaryflags[param1][_loc7_ * 2] && !boundaryflags[param2[_loc7_]][(_loc7_ * 2 + 4) % 8];
            _loc10_ = boundaryflags[param1][_loc7_ * 2 + 1] && !boundaryflags[param2[_loc7_]][(_loc7_ * 2 + 1 + 4) % 8];
            if(_loc9_)
            {
               if(_loc10_)
               {
                  _loc6_.push(boundarydefs[_loc7_ * 3 + 2].GenerateCollisionSegment(param3,param4,param5));
               }
               else
               {
                  _loc6_.push(boundarydefs[_loc7_ * 3].GenerateCollisionSegment(param3,param4,param5));
               }
            }
            else if(_loc10_)
            {
               _loc6_.push(boundarydefs[_loc7_ * 3 + 1].GenerateCollisionSegment(param3,param4,param5));
            }
            _loc7_++;
         }
         var _loc8_:TileEdgeArchetype = segdefs[param1];
         if(_loc8_ != null)
         {
            _loc6_.push(_loc8_.GenerateCollisionSegment(param3,param4,param5));
         }
         return _loc6_;
      }
      
      public static function GenerateTileSegments(param1:int, param2:Number, param3:Number, param4:Number) : Vector.<Segment>
      {
         var _loc9_:Boolean = false;
         var _loc10_:Boolean = false;
         if(param1 < 0 || param1 >= tiletypes.num_tile_types)
         {
            trace("WARNING! GenerateTileSegments() was passed an invalid tiletype: " + param1);
            return null;
         }
         var _loc5_:Vector.<Segment> = new Vector.<Segment>();
         var _loc6_:Vector.<Boolean> = boundaryflags[param1];
         var _loc7_:int = 0;
         while(_loc7_ < 4)
         {
            _loc9_ = _loc6_[_loc7_ * 2];
            _loc10_ = _loc6_[_loc7_ * 2 + 1];
            if(_loc9_)
            {
               if(_loc10_)
               {
                  _loc5_.push(boundarydefs[_loc7_ * 3 + 2].GenerateCollisionSegment(param2,param3,param4));
               }
               else
               {
                  _loc5_.push(boundarydefs[_loc7_ * 3].GenerateCollisionSegment(param2,param3,param4));
               }
            }
            else if(_loc10_)
            {
               _loc5_.push(boundarydefs[_loc7_ * 3 + 1].GenerateCollisionSegment(param2,param3,param4));
            }
            _loc7_++;
         }
         var _loc8_:TileEdgeArchetype = segdefs[param1];
         if(_loc8_ != null)
         {
            _loc5_.push(_loc8_.GenerateCollisionSegment(param2,param3,param4));
         }
         return _loc5_;
      }
      
      private static function HELPER_InitBoundaryFlags() : void
      {
         var _loc2_:int = 0;
         var _loc1_:int = 0;
         while(_loc1_ < tiletypes.num_tile_types)
         {
            boundaryflags[_loc1_] = new Vector.<Boolean>(8,true);
            _loc2_ = 0;
            while(_loc2_ < 8)
            {
               boundaryflags[_loc1_][_loc2_] = false;
               _loc2_++;
            }
            _loc1_++;
         }
      }
      
      private static function HELPER_SetBoundaryFlags_Copy(param1:int, param2:int) : void
      {
         var _loc3_:int = 0;
         while(_loc3_ < 8)
         {
            boundaryflags[param2][_loc3_] = boundaryflags[param1][_loc3_];
            _loc3_++;
         }
      }
      
      private static function HELPER_SetBoundaryFlags_Perp(param1:int, param2:int) : void
      {
         var _loc3_:int = 0;
         while(_loc3_ < 8)
         {
            boundaryflags[param2][_loc3_] = boundaryflags[param1][perpindex[_loc3_]];
            _loc3_++;
         }
      }
   }
}

