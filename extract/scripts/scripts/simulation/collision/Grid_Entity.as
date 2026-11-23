package simulation.collision
{
   import math.vec2;
   import simpleFramework.SimpleRenderer;
   import simulation.entities.Entity_Base;
   
   public class Grid_Entity extends Grid_Base
   {
      
      private var cells:Vector.<Vector.<Entity_Base>>;
      
      public function Grid_Entity(param1:int, param2:int, param3:Number)
      {
         super(param1,param2,param3);
         this.cells = new Vector.<Vector.<Entity_Base>>(numcells,true);
         var _loc4_:int = 0;
         while(_loc4_ < numcells)
         {
            this.cells[_loc4_] = new Vector.<Entity_Base>();
            _loc4_++;
         }
      }
      
      public function Debug_Draw(param1:SimpleRenderer) : void
      {
         var _loc3_:int = 0;
         var _loc4_:vec2 = null;
         param1.SetStyle(0,2237064,100);
         var _loc2_:int = 0;
         while(_loc2_ < numcols)
         {
            _loc3_ = 0;
            while(_loc3_ < numrows)
            {
               _loc4_ = new vec2((0.5 + _loc2_) * cellsize,(0.5 + _loc3_) * cellsize);
               param1.DrawStringAtPosition("" + this.cells[GetCellIndexFromGridspacePosition(_loc2_,_loc3_)].length,_loc4_.x,_loc4_.y);
               _loc3_++;
            }
            _loc2_++;
         }
      }
      
      public function Clear() : void
      {
         var _loc2_:Vector.<Entity_Base> = null;
         var _loc1_:int = 0;
         while(_loc1_ < numcells)
         {
            _loc2_ = this.cells[_loc1_];
            _loc2_.length = 0;
            _loc1_++;
         }
      }
      
      public function ENTITY_Move(param1:vec2, param2:Entity_Base) : void
      {
         var _loc3_:int = param2.GRID_GetGridIndex();
         var _loc4_:int = GetCellIndexFromWorldspacePosition(param1.x,param1.y);
         if(_loc3_ != _loc4_)
         {
            if(_loc3_ == -1)
            {
               trace("WARNING! ENTITY_Move() was called with an entity that\'s not in the grid: " + param2.GetUID());
            }
            else
            {
               this.RemoveEntityFromCell(_loc3_,param2);
               this.InsertEntityIntoCell(_loc4_,param2);
               param2.GRID_SetGridIndex(_loc4_);
            }
         }
      }
      
      public function ENTITY_Remove(param1:Entity_Base) : void
      {
         var _loc2_:int = param1.GRID_GetGridIndex();
         if(_loc2_ == -1)
         {
            trace("WARNING! ENTITY_Remove() was called with an entity that\'s not in the grid: " + param1.GetUID());
         }
         else
         {
            this.RemoveEntityFromCell(_loc2_,param1);
            param1.GRID_SetGridIndex(-1);
         }
      }
      
      public function ENTITY_Add(param1:vec2, param2:Entity_Base) : void
      {
         var _loc4_:int = 0;
         var _loc3_:int = param2.GRID_GetGridIndex();
         if(_loc3_ != -1)
         {
            trace("WARNING! ENTITY_Add() was called with an entity that\'s already in the grid: " + param2.GetUID() + "," + _loc3_);
         }
         else
         {
            _loc4_ = GetCellIndexFromWorldspacePosition(param1.x,param1.y);
            this.InsertEntityIntoCell(_loc4_,param2);
            param2.GRID_SetGridIndex(_loc4_);
         }
      }
      
      private function RemoveEntityFromCell(param1:int, param2:Entity_Base) : void
      {
         var _loc3_:Vector.<Entity_Base> = this.cells[param1];
         var _loc4_:int = int(_loc3_.indexOf(param2));
         if(_loc4_ == -1)
         {
            trace("WARNING! RemoveEntityFromCell() found an out-of-sync cell index: " + param1);
         }
         else
         {
            _loc3_.splice(_loc4_,1);
         }
      }
      
      private function InsertEntityIntoCell(param1:int, param2:Entity_Base) : void
      {
         var _loc3_:Vector.<Entity_Base> = this.cells[param1];
         _loc3_.push(param2);
      }
      
      public function GatherCellContentsInNeighbourhood(param1:vec2, param2:Vector.<Entity_Base>) : void
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:Vector.<Entity_Base> = null;
         var _loc9_:int = 0;
         param2.length = 0;
         var _loc3_:int = WorldspaceToGridspace(param1.x);
         var _loc4_:int = WorldspaceToGridspace(param1.y);
         var _loc5_:int = -1;
         while(_loc5_ < 2)
         {
            _loc6_ = -1;
            while(_loc6_ < 2)
            {
               _loc7_ = GetCellIndexFromGridspacePosition(_loc3_ + _loc5_,_loc4_ + _loc6_);
               _loc8_ = this.cells[_loc7_];
               _loc9_ = 0;
               while(_loc9_ < _loc8_.length)
               {
                  param2.push(_loc8_[_loc9_]);
                  _loc9_++;
               }
               _loc6_++;
            }
            _loc5_++;
         }
      }
   }
}

