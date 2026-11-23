package com.metanet.screens.menu
{
   import com.metanet.global.RootURLS;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import org.robotlegs.mvcs.Mediator;
   
   public class LogoMediator extends Mediator
   {
      
      public function LogoMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         addViewListener(MouseEvent.CLICK,this.handleClick);
      }
      
      private function handleClick(param1:MouseEvent) : void
      {
         navigateToURL(new URLRequest(RootURLS.metanetSite),"_blank");
      }
   }
}

