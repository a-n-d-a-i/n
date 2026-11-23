package com.metanet.screens.levels.userlevels
{
   public class Rate4Mediator extends RatingMediator
   {
      
      [Inject]
      public var view:Rate4Button;
      
      public function Rate4Mediator()
      {
         super();
         _rating = 4;
      }
      
      override public function onRegister() : void
      {
         _view = this.view;
         super.onRegister();
      }
   }
}

