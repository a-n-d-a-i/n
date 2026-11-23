package simulation.collision
{
   import math.vec2;
   
   public class Grid_Base
   {
      
      protected var numcols:int;
      
      protected var numrows:int;
      
      protected var numcells:int;
      
      protected var cellsize:Number;
      
      public function Grid_Base(param1:int, param2:int, param3:Number)
      {
         super();
         this.numcols = param1;
         this.numrows = param2;
         this.cellsize = param3;
         this.numcells = this.numcols * this.numrows;
      }
      
      final protected function WorldspaceToGridspace(param1:Number) : int
      {
         return Math.floor(param1 / this.cellsize);
      }
      
      final protected function GetCellIndexFromWorldspacePosition(param1:Number, param2:Number) : int
      {
         return this.GetCellIndexFromGridspacePosition(this.WorldspaceToGridspace(param1),this.WorldspaceToGridspace(param2));
      }
      
      final protected function GetCellIndexFromGridspacePosition(param1:int, param2:int) : int
      {
         if(param1 < 0 || param1 >= this.numcols || param2 < 0 || param2 >= this.numrows)
         {
            param1 = Math.max(0,Math.min(this.numcols - 1,param1));
            param2 = Math.max(0,Math.min(this.numrows - 1,param2));
         }
         return param2 * this.numcols + param1;
      }
      
      final public function DEBUG_GetWorldspaceCellCenterPositionFromIndex(param1:int) : vec2
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(param1 != -1)
         {
            _loc2_ = param1 % this.numcols;
            _loc3_ = Math.floor(param1 / this.numcols);
            return new vec2((_loc2_ + 0.5) * this.cellsize,(_loc3_ + 0.5) * this.cellsize);
         }
         return null;
      }
   }
}

