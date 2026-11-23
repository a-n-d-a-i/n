package tiles
{
   import simulation.collision.Segment;
   import simulation.collision.Segment_Linear;
   
   public class TileEdgeArchetype_Linear implements TileEdgeArchetype
   {
      
      private var x0:Number;
      
      private var y0:Number;
      
      private var x1:Number;
      
      private var y1:Number;
      
      public function TileEdgeArchetype_Linear(param1:Number, param2:Number, param3:Number, param4:Number)
      {
         super();
         this.x0 = param1;
         this.y0 = param2;
         this.x1 = param3;
         this.y1 = param4;
      }
      
      public function GeneratePerpArchetype() : TileEdgeArchetype
      {
         return new TileEdgeArchetype_Linear(-this.y0,this.x0,-this.y1,this.x1);
      }
      
      public function GenerateCollisionSegment(param1:Number, param2:Number, param3:Number) : Segment
      {
         return new Segment_Linear(param1 + this.x0 * param3,param2 + this.y0 * param3,param1 + this.x1 * param3,param2 + this.y1 * param3);
      }
   }
}

