package com.metanet.screens.credits
{
   import com.goldengear.utils.GeneralUtils;
   import com.metanet.ui.GlobalKeys;
   import com.metanet.ui.KeyboardNavigator;
   import flash.display.Stage;
   import flash.events.KeyboardEvent;
   import org.robotlegs.mvcs.Mediator;
   
   public class CreditsMediator extends Mediator
   {
      
      [Inject]
      public var view:CreditsScreen;
      
      [Inject]
      public var keyMapping:GlobalKeys;
      
      private var _stage:Stage;
      
      private var _navigator:KeyboardNavigator;
      
      public function CreditsMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         super.onRegister();
         this._stage = this.view.stage;
         this._stage.addEventListener(KeyboardEvent.KEY_DOWN,this.handleKeyDown);
         this._navigator = new KeyboardNavigator();
         this._navigator.useMapping(this.keyMapping);
         this._navigator.setReturnButton(this.view.returnButton);
         this._stage = this.view.stage;
         this._stage.addEventListener(KeyboardEvent.KEY_DOWN,this.handleKeyDown);
         addViewListener(KeyboardEvent.KEY_DOWN,this.handleKeyDown);
      }
      
      override public function onRemove() : void
      {
         if(this._stage)
         {
            this._stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.handleKeyDown);
         }
         this._stage = null;
         GeneralUtils.smartDestroy(this.view);
         super.onRemove();
      }
      
      private function handleKeyDown(param1:KeyboardEvent) : void
      {
         this._navigator.navigate(param1.keyCode);
      }
   }
}

