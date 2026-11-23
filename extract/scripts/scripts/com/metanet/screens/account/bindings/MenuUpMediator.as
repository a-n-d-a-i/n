package com.metanet.screens.account.bindings
{
   import com.metanet.global.SavedProperties;
   import com.metanet.ui.GlobalKeys;
   import flash.events.KeyboardEvent;
   
   public class MenuUpMediator extends MenuKeyBindingMediator
   {
      
      [Inject]
      public var menuKeys:GlobalKeys;
      
      [Inject]
      public var view:KeyBindingMenuUp;
      
      public function MenuUpMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         _keyCode = this.menuKeys.up;
         _keySaveName = SavedProperties.MENU_CONFIG_UP;
         _stage = this.view.stage;
         super.onRegister();
      }
      
      override protected function handleKeyDown(param1:KeyboardEvent) : void
      {
         super.handleKeyDown(param1);
         this.menuKeys.up = param1.keyCode;
      }
      
      override protected function setLabel(param1:String) : void
      {
         this.view.text = param1;
      }
   }
}

