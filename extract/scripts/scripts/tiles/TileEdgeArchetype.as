package tiles
{
   import simulation.collision.Segment;
   
   public interface TileEdgeArchetype
   {
      
      function GeneratePerpArchetype() : TileEdgeArchetype;
      
      function GenerateCollisionSegment(param1:Number, param2:Number, param3:Number) : Segment;
   }
}

