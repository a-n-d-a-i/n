package com.metanet.screens.account.bindings
{
   import com.metanet.global.SavedProperties;
   import com.metanet.ui.GlobalKeys;
   import flash.events.KeyboardEvent;
   
   public class MenuPauseMediator extends MenuKeyBindingMediator
   {
      
      [Inject]
      public var globalKeys:GlobalKeys;
      
      [Inject]
      public var view:KeyBindingPause;
      
      public function MenuPauseMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         _keyCode = this.globalKeys.pause;
         _keySaveName = SavedProperties.MENU_CONFIG_PAUSE;
         _stage = this.view.stage;
         super.onRegister();
      }
      
      override protected function handleKeyDown(param1:KeyboardEvent) : void
      {
         super.handleKeyDown(param1);
         this.globalKeys.pause = param1.keyCode;
      }
      
      override protected function setLabel(param1:String) : void
      {
         this.view.text = param1;
      }
   }
}

