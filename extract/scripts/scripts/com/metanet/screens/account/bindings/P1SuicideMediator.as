package com.metanet.screens.account.bindings
{
   import com.metanet.ui.PlayerKeys;
   
   public class P1SuicideMediator extends CoopKeyBindingMediator
   {
      
      public function P1SuicideMediator()
      {
         super();
         _keyName = "suicide";
         _action = PlayerKeys.SUICIDE;
         _player = 0;
      }
   }
}

