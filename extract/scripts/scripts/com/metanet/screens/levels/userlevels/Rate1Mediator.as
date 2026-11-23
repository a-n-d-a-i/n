package com.metanet.screens.levels.userlevels
{
   public class Rate1Mediator extends RatingMediator
   {
      
      [Inject]
      public var view:Rate1Button;
      
      public function Rate1Mediator()
      {
         super();
         _rating = 1;
      }
      
      override public function onRegister() : void
      {
         _view = this.view;
         super.onRegister();
      }
   }
}

