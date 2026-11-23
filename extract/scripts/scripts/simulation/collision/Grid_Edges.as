package simulation.collision
{
   import math.vec2;
   import simpleFramework.SimpleRenderer;
   import tiles.edgedefs;
   import tiles.edgetypes;
   
   public class Grid_Edges extends Grid_Base
   {
      
      private var edges_tileX:Vector.<int>;
      
      private var edges_tileY:Vector.<int>;
      
      private var edges_doorX:Vector.<int>;
      
      private var edges_doorY:Vector.<int>;
      
      public function Grid_Edges(param1:int, param2:int, param3:Number)
      {
         super(param1,param2,param3);
         this.edges_tileX = new Vector.<int>(numcells,true);
         this.edges_tileY = new Vector.<int>(numcells,true);
         this.edges_doorX = new Vector.<int>(numcells,true);
         this.edges_doorY = new Vector.<int>(numcells,true);
      }
      
      public function Clear() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < numcells)
         {
            this.edges_tileX[_loc1_] = edgetypes.EMPTY;
            this.edges_tileY[_loc1_] = edgetypes.EMPTY;
            this.edges_doorX[_loc1_] = 0;
            this.edges_doorY[_loc1_] = 0;
            _loc1_++;
         }
      }
      
      public function Debug_Draw(param1:SimpleRenderer) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Number = NaN;
         var _loc5_:int = 0;
         var _loc6_:vec2 = null;
         var _loc2_:int = 0;
         while(_loc2_ < numcols)
         {
            _loc3_ = 0;
            while(_loc3_ < numrows)
            {
               _loc4_ = cellsize * 0.5;
               _loc5_ = GetCellIndexFromGridspacePosition(_loc2_,_loc3_);
               _loc6_ = DEBUG_GetWorldspaceCellCenterPositionFromIndex(_loc5_);
               if(this.edges_tileX[_loc5_] != edgetypes.EMPTY)
               {
                  if(this.edges_tileX[_loc5_] == edgetypes.PARTIAL)
                  {
                     param1.SetStyle(0,11184810,100);
                  }
                  else
                  {
                     param1.SetStyle(0,2236962,100);
                  }
                  param1.DrawLine(_loc6_.x + _loc4_ - 2,_loc6_.y - _loc4_ + 2,_loc6_.x + _loc4_ - 2,_loc6_.y + _loc4_ - 2);
               }
               if(this.edges_tileY[_loc5_] != edgetypes.EMPTY)
               {
                  if(this.edges_tileY[_loc5_] == edgetypes.PARTIAL)
                  {
                     param1.SetStyle(0,11184810,100);
                  }
                  else
                  {
                     param1.SetStyle(0,2236962,100);
                  }
                  param1.DrawLine(_loc6_.x - _loc4_ + 2,_loc6_.y + _loc4_ - 2,_loc6_.x + _loc4_ - 2,_loc6_.y + _loc4_ - 2);
               }
               param1.SetStyle(0,2263074,100);
               if(this.edges_doorX[_loc5_] != 0)
               {
                  param1.DrawAABB(_loc6_.x + _loc4_ - 2,_loc6_.x + _loc4_ + 2,_loc6_.y - _loc4_ + 2,_loc6_.y + _loc4_ - 2);
               }
               if(this.edges_doorY[_loc5_] != 0)
               {
                  param1.DrawAABB(_loc6_.x - _loc4_ + 2,_loc6_.x + _loc4_ - 2,_loc6_.y + _loc4_ - 2,_loc6_.y + _loc4_ + 2);
               }
               _loc3_++;
            }
            _loc2_++;
         }
      }
      
      public function DOOR_GetCellIndexFromGridspacePosition(param1:int, param2:int) : int
      {
         return GetCellIndexFromGridspacePosition(param1,param2);
      }
      
      public function GetGridCoordinateFromWorldspace_1D(param1:Number) : int
      {
         return WorldspaceToGridspace(param1);
      }
      
      public function GetWorldspaceCoordinateFromGridEdge_1D(param1:int, param2:int) : int
      {
         return (param1 + Math.max(0,param2)) * cellsize;
      }
      
      public function IsSolid(param1:int, param2:int, param3:int, param4:int) : Boolean
      {
         var _loc5_:int = this.GetIndexFromGridspaceAndOffset(param1,param2,param3,param4);
         if(param4 == 0)
         {
            return this.edges_tileX[_loc5_] == edgetypes.SOLID || this.edges_doorX[_loc5_] != 0;
         }
         return this.edges_tileY[_loc5_] == edgetypes.SOLID || this.edges_doorY[_loc5_] != 0;
      }
      
      public function IsSolid_IgnoreDoors(param1:int, param2:int, param3:int, param4:int) : Boolean
      {
         var _loc5_:int = this.GetIndexFromGridspaceAndOffset(param1,param2,param3,param4);
         if(param4 == 0)
         {
            return this.edges_tileX[_loc5_] == edgetypes.SOLID;
         }
         return this.edges_tileY[_loc5_] == edgetypes.SOLID;
      }
      
      public function IsEmpty(param1:int, param2:int, param3:int, param4:int) : Boolean
      {
         var _loc5_:int = this.GetIndexFromGridspaceAndOffset(param1,param2,param3,param4);
         if(param4 == 0)
         {
            return this.edges_tileX[_loc5_] == edgetypes.EMPTY && this.edges_doorX[_loc5_] == 0;
         }
         return this.edges_tileY[_loc5_] == edgetypes.EMPTY && this.edges_doorY[_loc5_] == 0;
      }
      
      public function ScanHorizontal(param1:int, param2:int, param3:int, param4:int) : Boolean
      {
         var _loc6_:int = 0;
         var _loc5_:int = param4 - param3;
         if(_loc5_ != 0)
         {
            _loc6_ = _loc5_ / Math.abs(_loc5_);
            return this.ScanHorizontal_Directed(param1,param2,param3,param4,_loc6_);
         }
         return true;
      }
      
      public function ScanHorizontal_Directed(param1:int, param2:int, param3:int, param4:int, param5:int) : Boolean
      {
         var _loc6_:int = param3;
         while(_loc6_ != param4)
         {
            if(!this.IsEmpty_Column(_loc6_,param1,param2,param5))
            {
               return false;
            }
            _loc6_ += param5;
            if(Math.abs(_loc6_) > 100)
            {
               trace("-infinite loop in ScanHorizontal: " + param1 + "-" + param2 + " .. " + param3 + "," + param5);
               return false;
            }
         }
         return true;
      }
      
      public function ScanVertical(param1:int, param2:int, param3:int, param4:int) : Boolean
      {
         var _loc6_:int = 0;
         var _loc5_:int = param4 - param3;
         if(_loc5_ != 0)
         {
            _loc6_ = _loc5_ / Math.abs(_loc5_);
            return this.ScanVertical_Directed(param1,param2,param3,param4,_loc6_);
         }
         return true;
      }
      
      public function ScanVertical_Directed(param1:int, param2:int, param3:int, param4:int, param5:int) : Boolean
      {
         var _loc6_:int = param3;
         while(_loc6_ != param4)
         {
            if(!this.IsEmpty_Row(_loc6_,param1,param2,param5))
            {
               return false;
            }
            _loc6_ += param5;
            if(Math.abs(_loc6_) > 100)
            {
               trace("-infinite loop in ScanVertical: " + param1 + "-" + param2 + " .. " + param3 + "," + param5);
               return false;
            }
         }
         return true;
      }
      
      public function SweepHorizontal(param1:int, param2:int, param3:int, param4:int) : int
      {
         var _loc5_:int = param3;
         while(this.IsEmpty_Column(_loc5_,param1,param2,param4))
         {
            _loc5_ += param4;
            if(Math.abs(_loc5_) > 100)
            {
               trace("-infinite loop in SweepHorizontal: " + param1 + "-" + param2 + " .. " + param3 + "," + param4);
               return param3;
            }
         }
         return _loc5_;
      }
      
      public function SweepVertical(param1:int, param2:int, param3:int, param4:int) : int
      {
         var _loc5_:int = param3;
         while(this.IsEmpty_Row(_loc5_,param1,param2,param4))
         {
            _loc5_ += param4;
            if(Math.abs(_loc5_) > 100)
            {
               trace("-infinite loop in SweepVertical: " + param1 + "-" + param2 + " .. " + param3 + "," + param4);
               return param3;
            }
         }
         return _loc5_;
      }
      
      public function IsEmpty_Column(param1:int, param2:int, param3:int, param4:int) : Boolean
      {
         var _loc5_:int = param2;
         while(_loc5_ <= param3)
         {
            if(!this.IsEmpty(param1,_loc5_,param4,0))
            {
               return false;
            }
            _loc5_++;
         }
         return true;
      }
      
      public function IsEmpty_Row(param1:int, param2:int, param3:int, param4:int) : Boolean
      {
         var _loc5_:int = param2;
         while(_loc5_ <= param3)
         {
            if(!this.IsEmpty(_loc5_,param1,0,param4))
            {
               return false;
            }
            _loc5_++;
         }
         return true;
      }
      
      public function GAME_LoadTileEdges(param1:int, param2:int, param3:int) : void
      {
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc4_:int = param1 * 2;
         var _loc5_:int = param2 * 2;
         var _loc6_:int = 0;
         while(_loc6_ < 3)
         {
            _loc7_ = 0;
            while(_loc7_ < 2)
            {
               _loc8_ = _loc4_ - 1 + _loc6_;
               _loc9_ = _loc5_ + _loc7_;
               _loc10_ = _loc4_ + _loc7_;
               _loc11_ = _loc5_ - 1 + _loc6_;
               _loc12_ = GetCellIndexFromGridspacePosition(_loc8_,_loc9_);
               _loc13_ = GetCellIndexFromGridspacePosition(_loc10_,_loc11_);
               _loc14_ = _loc6_ + _loc7_ * 3;
               this.LoadEdgeState_X(_loc12_,edgedefs.GetEdgeState_X(param3,_loc14_));
               this.LoadEdgeState_Y(_loc13_,edgedefs.GetEdgeState_Y(param3,_loc14_));
               _loc7_++;
            }
            _loc6_++;
         }
      }
      
      public function DOOR_IncrementEdge(param1:int, param2:Boolean) : void
      {
         if(param1 < 0 || param1 >= numcells)
         {
            trace("WARNING! DOOR_IncrementEdge() was called with an invalid index: " + param1);
            return;
         }
         if(param2)
         {
            this.edges_doorX[param1] += 1;
         }
         else
         {
            this.edges_doorY[param1] += 1;
         }
      }
      
      public function DOOR_DecrementEdge(param1:int, param2:Boolean) : void
      {
         if(param1 < 0 || param1 >= numcells)
         {
            trace("WARNING! DOOR_DecrementEdge() was called with an invalid index: " + param1);
            return;
         }
         if(param2)
         {
            if(this.edges_doorX[param1] <= 0)
            {
               trace("WARNING! DOOR_DecrementEdge() was called on an empty edge! " + param1);
               return;
            }
            this.edges_doorX[param1] = this.edges_doorX[param1] - 1;
         }
         else
         {
            if(this.edges_doorY[param1] <= 0)
            {
               trace("WARNING! DOOR_DecrementEdge() was called on an empty edge! " + param1);
               return;
            }
            this.edges_doorY[param1] = this.edges_doorY[param1] - 1;
         }
      }
      
      private function GetIndexFromGridspaceAndOffset(param1:int, param2:int, param3:int, param4:int) : int
      {
         var _loc5_:int = -1;
         if(param4 == 0)
         {
            if(param3 == -1)
            {
               _loc5_ = GetCellIndexFromGridspacePosition(param1 - 1,param2);
            }
            else if(param3 == 1)
            {
               _loc5_ = GetCellIndexFromGridspacePosition(param1,param2);
            }
         }
         else if(param3 == 0)
         {
            if(param4 == -1)
            {
               _loc5_ = GetCellIndexFromGridspacePosition(param1,param2 - 1);
            }
            else if(param4 == 1)
            {
               _loc5_ = GetCellIndexFromGridspacePosition(param1,param2);
            }
         }
         return _loc5_;
      }
      
      private function LoadEdgeState_X(param1:int, param2:int) : void
      {
         if(this.edges_tileX[param1] == edgetypes.SOLID && param2 == edgetypes.SOLID)
         {
            this.edges_tileX[param1] = edgetypes.EMPTY;
         }
         else
         {
            this.edges_tileX[param1] = Math.max(this.edges_tileX[param1],param2);
         }
      }
      
      private function LoadEdgeState_Y(param1:int, param2:int) : void
      {
         if(this.edges_tileY[param1] == edgetypes.SOLID && param2 == edgetypes.SOLID)
         {
            this.edges_tileY[param1] = edgetypes.EMPTY;
         }
         else
         {
            this.edges_tileY[param1] = Math.max(this.edges_tileY[param1],param2);
         }
      }
      
      private function SetDoorState_X(param1:int, param2:int) : void
      {
         this.edges_doorX[param1] = param2;
      }
      
      private function SetDoorState_Y(param1:int, param2:int) : void
      {
         this.edges_doorY[param1] = param2;
      }
   }
}

