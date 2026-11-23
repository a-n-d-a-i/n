package simulation.collision
{
   import math.vec2;
   import simpleFramework.SimpleRenderer;
   
   public class Grid_Segment extends Grid_Base
   {
      
      private var cells:Vector.<Vector.<Segment>>;
      
      private var TEMP_ray_pos:vec2;
      
      private var TEMP_ray_vec:vec2;
      
      private var TEMP_temp_p:vec2;
      
      private var TEMP_temp_n:vec2;
      
      public function Grid_Segment(param1:int, param2:int, param3:Number)
      {
         super(param1,param2,param3);
         this.cells = new Vector.<Vector.<Segment>>(numcells,true);
         var _loc4_:int = 0;
         while(_loc4_ < numcells)
         {
            this.cells[_loc4_] = new Vector.<Segment>();
            _loc4_++;
         }
         this.TEMP_ray_pos = new vec2();
         this.TEMP_ray_vec = new vec2();
         this.TEMP_temp_p = new vec2();
         this.TEMP_temp_n = new vec2();
      }
      
      public function DEBUG_Draw(param1:SimpleRenderer) : void
      {
         var _loc3_:int = 0;
         var _loc2_:int = 0;
         while(_loc2_ < this.cells.length)
         {
            _loc3_ = 0;
            while(_loc3_ < this.cells[_loc2_].length)
            {
               this.cells[_loc2_][_loc3_].DebugDraw(param1);
               _loc3_++;
            }
            _loc2_++;
         }
      }
      
      public function GetRaycastDistance(param1:Number, param2:Number, param3:Number, param4:Number, param5:vec2, param6:vec2) : Number
      {
         var _loc17_:Number = NaN;
         var _loc7_:int = WorldspaceToGridspace(param1);
         var _loc8_:int = WorldspaceToGridspace(param2);
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:Number = 999999;
         var _loc12_:Number = 999999;
         var _loc13_:Number = 0;
         var _loc14_:Number = 0;
         if(param3 < 0)
         {
            _loc9_ = -1;
            _loc11_ = (_loc7_ * cellsize - param1) / param3;
            _loc13_ = cellsize / -param3;
         }
         else if(param3 > 0)
         {
            _loc9_ = 1;
            _loc11_ = ((_loc7_ + 1) * cellsize - param1) / param3;
            _loc13_ = cellsize / param3;
         }
         if(param4 < 0)
         {
            _loc10_ = -1;
            _loc12_ = (_loc8_ * cellsize - param2) / param4;
            _loc14_ = cellsize / -param4;
         }
         else if(param4 > 0)
         {
            _loc10_ = 1;
            _loc12_ = ((_loc8_ + 1) * cellsize - param2) / param4;
            _loc14_ = cellsize / param4;
         }
         if(_loc9_ == 0 && _loc10_ == 0)
         {
            trace("WARNING! some jackass called GetRaycastDistance() with a null ray vector: " + param3 + "," + param4);
            return -1;
         }
         var _loc15_:Number = 2000;
         this.TEMP_ray_pos.x = param1;
         this.TEMP_ray_pos.y = param2;
         this.TEMP_ray_vec.x = _loc15_ * param3;
         this.TEMP_ray_vec.y = _loc15_ * param4;
         var _loc16_:Number = 2;
         while(true)
         {
            _loc17_ = this.IntersectRayVsCellContents(_loc7_,_loc8_,this.TEMP_ray_pos,this.TEMP_ray_vec,param5,param6);
            if(_loc17_ == -1)
            {
               break;
            }
            if(_loc17_ != 2)
            {
               _loc16_ = _loc17_;
               return _loc16_ * _loc15_;
            }
            if(_loc11_ < _loc12_)
            {
               _loc11_ += _loc13_;
               _loc7_ += _loc9_;
               if(_loc7_ < 0 || _loc7_ >= numcols)
               {
                  trace("WARNING! GetRaycastDistance() has a ray that missed everything in U");
                  return -1;
               }
            }
            else
            {
               _loc12_ += _loc14_;
               _loc8_ += _loc10_;
               if(_loc8_ < 0 || _loc8_ >= numrows)
               {
                  trace("WARNING! GetRaycastDistance() has a ray that missed everything in V");
                  return -1;
               }
            }
         }
         trace("WARNING! GetRaycastDistance() was passed an invalid ray (start position overlaps seg geometry)");
         return -1;
      }
      
      public function RaycastVsPlayer(param1:vec2, param2:vec2, param3:Number, param4:vec2, param5:vec2) : Boolean
      {
         var _loc9_:Number = NaN;
         var _loc6_:Number = param2.x - param1.x;
         var _loc7_:Number = param2.y - param1.y;
         var _loc8_:Number = Math.sqrt(_loc6_ * _loc6_ + _loc7_ * _loc7_);
         if(_loc8_ < param3)
         {
            return true;
         }
         _loc6_ /= _loc8_;
         _loc7_ /= _loc8_;
         _loc8_ -= param3;
         _loc9_ = this.GetRaycastDistance(param1.x,param1.y,_loc6_,_loc7_,param4,param5);
         if(_loc8_ < _loc9_)
         {
            return true;
         }
         if(_loc9_ == -1)
         {
            param4.x = 0;
            param4.y = 0;
            param5.x = 1;
            param5.y = 0;
            trace("WARNING! RaycastVsPlayer() has a problem ray");
         }
         return false;
      }
      
      private function IntersectRayVsCellContents(param1:int, param2:int, param3:vec2, param4:vec2, param5:vec2, param6:vec2) : Number
      {
         var _loc11_:Segment = null;
         var _loc12_:Number = NaN;
         var _loc7_:Number = 2;
         this.TEMP_temp_p.x = 0;
         this.TEMP_temp_p.y = 0;
         this.TEMP_temp_n.x = 0;
         this.TEMP_temp_n.y = 0;
         var _loc8_:int = GetCellIndexFromGridspacePosition(param1,param2);
         var _loc9_:Vector.<Segment> = this.cells[_loc8_];
         var _loc10_:int = 0;
         while(_loc10_ < _loc9_.length)
         {
            _loc11_ = _loc9_[_loc10_];
            _loc12_ = _loc11_.IntersectWithRay(param3,param4,0,this.TEMP_temp_p,this.TEMP_temp_n);
            if(_loc12_ == -1)
            {
               return -1;
            }
            if(_loc12_ < _loc7_)
            {
               _loc7_ = _loc12_;
               param5.Copy(this.TEMP_temp_p);
               param6.Copy(this.TEMP_temp_n);
            }
            _loc10_++;
         }
         return _loc7_;
      }
      
      public function DEBUG_GetCellContentsFromGridspacePosition(param1:int, param2:int) : Vector.<Segment>
      {
         var _loc3_:int = GetCellIndexFromGridspacePosition(param1,param2);
         return this.cells[_loc3_];
      }
      
      public function Clear() : void
      {
         var _loc2_:Vector.<Segment> = null;
         var _loc1_:int = 0;
         while(_loc1_ < numcells)
         {
            _loc2_ = this.cells[_loc1_];
            _loc2_.length = 0;
            _loc1_++;
         }
      }
      
      public function AddSegToCell(param1:int, param2:int, param3:Segment) : void
      {
         var _loc4_:int = GetCellIndexFromGridspacePosition(param1,param2);
         if(_loc4_ < 0)
         {
            trace("WARNING! AddSegToCell() was passed invalid cell coords: " + param1 + "," + param2);
            return;
         }
         this.cells[_loc4_].push(param3);
      }
      
      public function DOOR_AddSegment(param1:int, param2:Segment) : void
      {
         if(param1 < 0 || param1 >= numcells)
         {
            trace("WARNING! DOOR_AddSegment() was called with an invalid index: " + param1);
            return;
         }
         var _loc3_:Vector.<Segment> = this.cells[param1];
         var _loc4_:int = int(_loc3_.indexOf(param2));
         if(_loc4_ != -1)
         {
            trace("WARNING! DOOR_AddSegment() was passed an already-in-grid seg: " + param1);
            return;
         }
         this.cells[param1].push(param2);
      }
      
      public function DOOR_RemoveSegment(param1:int, param2:Segment) : void
      {
         if(param1 < 0 || param1 >= numcells)
         {
            trace("WARNING! DOOR_RemoveSegment() was called with an invalid index: " + param1);
            return;
         }
         var _loc3_:Vector.<Segment> = this.cells[param1];
         var _loc4_:int = int(_loc3_.indexOf(param2));
         if(_loc4_ == -1)
         {
            trace("WARNING! DOOR_RemoveSegment() couldn\'t find a seg: " + param1);
            return;
         }
         _loc3_.splice(_loc4_,1);
      }
      
      public function DOOR_GetCellIndexFromGridspacePosition(param1:int, param2:int) : int
      {
         return GetCellIndexFromGridspacePosition(param1,param2);
      }
      
      public function GatherCellContentsFromWorldspaceRegion(param1:Number, param2:Number, param3:Number, param4:Number, param5:Vector.<Segment>) : void
      {
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:Vector.<Segment> = null;
         var _loc14_:int = 0;
         var _loc6_:int = WorldspaceToGridspace(param1);
         var _loc7_:int = WorldspaceToGridspace(param3);
         var _loc8_:int = WorldspaceToGridspace(param2);
         var _loc9_:int = WorldspaceToGridspace(param4);
         param5.length = 0;
         var _loc10_:int = _loc8_;
         while(_loc10_ <= _loc9_)
         {
            _loc11_ = _loc6_;
            while(_loc11_ <= _loc7_)
            {
               _loc12_ = GetCellIndexFromGridspacePosition(_loc11_,_loc10_);
               if(_loc12_ < 0)
               {
                  trace("WARNING! GatherCellContentsFromWorldspaceRegion() was passed an invalid region: " + _loc6_ + "," + _loc8_ + " .. " + _loc7_ + "," + _loc9_);
               }
               _loc13_ = this.cells[_loc12_];
               _loc14_ = 0;
               while(_loc14_ < _loc13_.length)
               {
                  param5.push(_loc13_[_loc14_]);
                  _loc14_++;
               }
               _loc11_++;
            }
            _loc10_++;
         }
      }
   }
}

