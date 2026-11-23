package audiovisual.entitygraphics
{
   import flash.display.DisplayObject;
   
   public interface EntityGraphics
   {
      
      function RegisterGraphics(param1:Vector.<DisplayObject>) : void;
      
      function UpdateState() : void;
   }
}

