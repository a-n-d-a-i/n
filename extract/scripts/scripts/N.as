package
{
   import flash.display.Sprite;
   import flash.display.StageScaleMode;
   import flash.events.Event;
   import flash.system.Security;
   import org.robotlegs.mvcs.Context;
   import simpleFramework.SimpleRenderer;
   
   public class N extends Sprite
   {
      
      public var menu_stage:Sprite;
      
      public var context:Context;
      
      public var rend:SimpleRenderer;
      
      public var screen:Sprite;
      
      public function N()
      {
         super();
         Security.loadPolicyFile("http://www.thewayoftheninja.org/crossdomain.xml");
         Security.loadPolicyFile("http://nserver.thewayoftheninja.org/crossdomain.xml");
         Security.allowInsecureDomain("*");
         addEventListener(Event.ADDED_TO_STAGE,this.handleAddedToStage);
      }
      
      private function handleAddedToStage(param1:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.handleAddedToStage);
         stage.scaleMode = StageScaleMode.NO_SCALE;
         stage.stageFocusRect = false;
         this.context = new AppContext(this);
      }
      
      public function createChildren() : void
      {
         this.menu_stage = new Sprite();
         addChild(this.menu_stage);
         this.menu_stage.x = 4;
      }
      
      public function changeScreen(param1:Sprite) : void
      {
         this.removeScreen();
         this.screen = param1;
         this.menu_stage.addChild(param1);
      }
      
      public function removeScreen() : void
      {
         if(this.screen)
         {
            this.menu_stage.removeChild(this.screen);
         }
         this.screen = null;
      }
   }
}

