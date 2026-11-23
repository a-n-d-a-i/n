package
{
   import flash.display.Sprite;
   import flash.events.Event;
   
   public class Preloader extends Sprite
   {
      
      private const LAST_FRAME:int = 502;
      
      private var view:PreloaderScreen;
      
      public function Preloader()
      {
         super();
         addEventListener(Event.ADDED_TO_STAGE,this.addedToStage);
      }
      
      private function addedToStage(param1:Event) : void
      {
         this.view = new PreloaderScreen();
         addChild(this.view);
         addEventListener(Event.ENTER_FRAME,this.enterFrame);
      }
      
      public function destroy() : void
      {
         if(parent)
         {
            parent.removeChild(this);
            removeEventListener(Event.ENTER_FRAME,this.enterFrame);
         }
      }
      
      private function enterFrame(param1:Event) : void
      {
         var _loc2_:Number = stage.loaderInfo.bytesLoaded / stage.loaderInfo.bytesTotal;
         this.view.timebar.gotoAndStop(int(this.LAST_FRAME * _loc2_));
         if(stage.loaderInfo.bytesLoaded == stage.loaderInfo.bytesTotal)
         {
            stage.addChild(new N());
            this.destroy();
         }
      }
   }
}

