package com.metanet.screens.levels.userlevels
{
   import flash.events.MouseEvent;
   import org.robotlegs.mvcs.Mediator;
   
   public class SearchSectionMediator extends Mediator
   {
      
      [Inject]
      public var view:SearchSection;
      
      public function SearchSectionMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         this.showSimple();
         this.view.simpleButton.addEventListener(MouseEvent.CLICK,this.handleClickSimple);
         this.view.advancedButton.addEventListener(MouseEvent.CLICK,this.handleClickAdvanced);
      }
      
      override public function onRemove() : void
      {
         this.view.simpleButton.removeEventListener(MouseEvent.CLICK,this.handleClickSimple);
         this.view.advancedButton.removeEventListener(MouseEvent.CLICK,this.handleClickAdvanced);
      }
      
      private function handleClickSimple(param1:MouseEvent) : void
      {
         this.showSimple();
      }
      
      private function handleClickAdvanced(param1:MouseEvent) : void
      {
         this.showAdvanced();
      }
      
      private function showSimple() : void
      {
         this.view.advanced.visible = false;
         this.view.simpleButton.visible = false;
         this.view.simple.visible = true;
         this.view.advancedButton.visible = true;
      }
      
      private function showAdvanced() : void
      {
         this.view.advanced.visible = true;
         this.view.simpleButton.visible = true;
         this.view.simple.visible = false;
         this.view.advancedButton.visible = false;
      }
   }
}

