package simulation.entities
{
   public class collision_result_physical
   {
      
      public var pen:Number;
      
      public var nx:Number;
      
      public var ny:Number;
      
      public var isHardCollision:Boolean;
      
      public function collision_result_physical()
      {
         super();
         this.Clear();
      }
      
      public function Clear() : void
      {
         this.pen = 0;
         this.nx = 0;
         this.ny = 0;
         this.isHardCollision = true;
      }
   }
}

