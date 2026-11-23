package com.metanet.screens.account.bindings
{
   import com.metanet.ui.PlayerKeys;
   
   public class P1LeftMediator extends CoopKeyBindingMediator
   {
      
      public function P1LeftMediator()
      {
         super();
         _keyName = "left";
         _action = PlayerKeys.LEFT;
         _player = 0;
      }
   }
}

