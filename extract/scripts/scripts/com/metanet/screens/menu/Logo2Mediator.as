package com.metanet.screens.menu
{
   import com.metanet.global.RootURLS;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import org.robotlegs.mvcs.Mediator;
   
   public class Logo2Mediator extends Mediator
   {
      
      public function Logo2Mediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         addViewListener(MouseEvent.CLICK,this.handleClick);
      }
      
      private function handleClick(param1:MouseEvent) : void
      {
         navigateToURL(new URLRequest(RootURLS.otherSite),"_blank");
      }
   }
}

