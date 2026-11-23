package com.metanet.screens.help
{
   import org.robotlegs.core.IMediatorMap;
   
   public class HelpMappings
   {
      
      public function HelpMappings()
      {
         super();
      }
      
      public static function mapMediators(param1:IMediatorMap) : void
      {
         param1.mapView(HelpScreen,HelpMediator);
      }
   }
}

