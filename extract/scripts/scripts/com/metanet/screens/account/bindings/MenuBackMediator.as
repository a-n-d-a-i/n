package com.metanet.screens.account.bindings
{
   import com.metanet.global.SavedProperties;
   import com.metanet.ui.GlobalKeys;
   import flash.events.KeyboardEvent;
   
   public class MenuBackMediator extends MenuKeyBindingMediator
   {
      
      [Inject]
      public var menuKeys:GlobalKeys;
      
      [Inject]
      public var view:KeyBindingMenuBack;
      
      public function MenuBackMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         _keyCode = this.menuKeys.back;
         _keySaveName = SavedProperties.MENU_CONFIG_BACK;
         _stage = this.view.stage;
         super.onRegister();
      }
      
      override protected function handleKeyDown(param1:KeyboardEvent) : void
      {
         super.handleKeyDown(param1);
         this.menuKeys.back = param1.keyCode;
      }
      
      override protected function setLabel(param1:String) : void
      {
         this.view.text = param1;
      }
   }
}

