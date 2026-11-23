package com.metanet.screens.menu
{
   import org.robotlegs.core.IMediatorMap;
   
   public class MenuMappings
   {
      
      public function MenuMappings()
      {
         super();
      }
      
      public static function mapMediators(param1:IMediatorMap) : void
      {
         param1.mapView(EpisodesButton,EpisodesButtonMediator);
         param1.mapView(UserLevelsButton,LevelsButtonMediator);
         param1.mapView(CreditsButton,CreditsButtonMediator);
         param1.mapView(HelpButton,HelpButtonMediator);
         param1.mapView(StoryButton,StoryButtonMediator);
         param1.mapView(MenuScreen,MenuMediator);
         param1.mapView(AccountButton,AccountButtonMediator);
         param1.mapView(Logo,LogoMediator);
         param1.mapView(Logo2,Logo2Mediator);
         param1.mapView(Logo3,Logo3Mediator);
      }
   }
}

