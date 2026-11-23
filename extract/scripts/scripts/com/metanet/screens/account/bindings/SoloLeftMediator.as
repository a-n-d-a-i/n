package com.metanet.screens.account.bindings
{
   import com.metanet.ui.PlayerKeys;
   
   public class SoloLeftMediator extends SoloKeyBindingMediator
   {
      
      public function SoloLeftMediator()
      {
         super();
         _keyName = "left";
         _action = PlayerKeys.LEFT;
         _player = 0;
      }
   }
}

