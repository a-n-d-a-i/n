package com.metanet.screens.account.bindings
{
   import com.metanet.global.SavedProperties;
   import com.metanet.ui.GlobalKeys;
   import flash.events.KeyboardEvent;
   
   public class MenuDownMediator extends MenuKeyBindingMediator
   {
      
      [Inject]
      public var menuKeys:GlobalKeys;
      
      [Inject]
      public var view:KeyBindingMenuDown;
      
      public function MenuDownMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         _keyCode = this.menuKeys.down;
         _keySaveName = SavedProperties.MENU_CONFIG_DOWN;
         _stage = this.view.stage;
         super.onRegister();
      }
      
      override protected function handleKeyDown(param1:KeyboardEvent) : void
      {
         super.handleKeyDown(param1);
         this.menuKeys.down = param1.keyCode;
      }
      
      override protected function setLabel(param1:String) : void
      {
         this.view.text = param1;
      }
   }
}

