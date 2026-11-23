package tiles
{
   import simulation.collision.Segment;
   import simulation.collision.Segment_Circular;
   
   public class TileEdgeArchetype_Circular implements TileEdgeArchetype
   {
      
      private var x0:Number;
      
      private var y0:Number;
      
      private var x1:Number;
      
      private var y1:Number;
      
      private var x2:Number;
      
      private var y2:Number;
      
      public function TileEdgeArchetype_Circular(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number)
      {
         super();
         this.x0 = param1;
         this.y0 = param2;
         this.x1 = param3;
         this.y1 = param4;
         this.x2 = param5;
         this.y2 = param6;
      }
      
      public function GeneratePerpArchetype() : TileEdgeArchetype
      {
         return new TileEdgeArchetype_Circular(-this.y0,this.x0,-this.y1,this.x1,-this.y2,this.x2);
      }
      
      public function GenerateCollisionSegment(param1:Number, param2:Number, param3:Number) : Segment
      {
         return new Segment_Circular(param1 + this.x2 * param3,param2 + this.y2 * param3,param1 + this.x0 * param3,param2 + this.y0 * param3,param1 + this.x1 * param3,param2 + this.y1 * param3);
      }
   }
}

