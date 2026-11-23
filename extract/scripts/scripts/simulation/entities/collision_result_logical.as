package simulation.entities
{
   public class collision_result_logical
   {
      
      public var vec_x:Number;
      
      public var vec_y:Number;
      
      public function collision_result_logical()
      {
         super();
         this.Clear();
      }
      
      public function Clear() : void
      {
         this.vec_x = 0;
         this.vec_y = 0;
      }
   }
}

