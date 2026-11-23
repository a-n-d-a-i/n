package com.metanet.screens.account.bindings
{
   import com.metanet.ui.DynamicButton;
   import org.robotlegs.core.IMediatorMap;
   
   public class BindingMappings
   {
      
      public function BindingMappings()
      {
         super();
      }
      
      public static function mapMediators(param1:IMediatorMap) : void
      {
         param1.mapView(KeyBindingMenuUp,MenuUpMediator);
         param1.mapView(KeyBindingMenuDown,MenuDownMediator);
         param1.mapView(KeyBindingMenuLeft,MenuLeftMediator);
         param1.mapView(KeyBindingMenuRight,MenuRightMediator);
         param1.mapView(KeyBindingMenuSelect,MenuSelectMediator);
         param1.mapView(KeyBindingMenuBack,MenuBackMediator);
         param1.mapView(KeyBindingPause,MenuPauseMediator);
         param1.mapView(KeyBindingJumpSolo,SoloJumpMediator,DynamicButton);
         param1.mapView(KeyBindingLeftSolo,SoloLeftMediator,DynamicButton);
         param1.mapView(KeyBindingRightSolo,SoloRightMediator,DynamicButton);
         param1.mapView(KeyBindingSuicideSolo,SoloSuicideMediator,DynamicButton);
         param1.mapView(KeyBindingJump1,P1JumpMediator,DynamicButton);
         param1.mapView(KeyBindingLeft1,P1LeftMediator,DynamicButton);
         param1.mapView(KeyBindingRight1,P1RightMediator,DynamicButton);
         param1.mapView(KeyBindingSuicide1,P1SuicideMediator,DynamicButton);
         param1.mapView(KeyBindingJump2,P2JumpMediator,DynamicButton);
         param1.mapView(KeyBindingLeft2,P2LeftMediator,DynamicButton);
         param1.mapView(KeyBindingRight2,P2RightMediator,DynamicButton);
         param1.mapView(KeyBindingSuicide2,P2SuicideMediator,DynamicButton);
      }
   }
}

