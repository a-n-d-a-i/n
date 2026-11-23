package com.metanet.screens.account.bindings
{
   import com.metanet.global.SavedProperties;
   import com.metanet.ui.GlobalKeys;
   import flash.events.KeyboardEvent;
   
   public class MenuSelectMediator extends MenuKeyBindingMediator
   {
      
      [Inject]
      public var menuKeys:GlobalKeys;
      
      [Inject]
      public var view:KeyBindingMenuSelect;
      
      public function MenuSelectMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         _keyCode = this.menuKeys.select;
         _keySaveName = SavedProperties.MENU_CONFIG_SELECT;
         _stage = this.view.stage;
         super.onRegister();
      }
      
      override protected function handleKeyDown(param1:KeyboardEvent) : void
      {
         super.handleKeyDown(param1);
         this.menuKeys.select = param1.keyCode;
      }
      
      override protected function setLabel(param1:String) : void
      {
         this.view.text = param1;
      }
   }
}

