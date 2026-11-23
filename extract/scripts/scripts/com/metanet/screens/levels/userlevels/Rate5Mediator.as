package com.metanet.screens.levels.userlevels
{
   public class Rate5Mediator extends RatingMediator
   {
      
      [Inject]
      public var view:Rate5Button;
      
      public function Rate5Mediator()
      {
         super();
         _rating = 5;
      }
      
      override public function onRegister() : void
      {
         _view = this.view;
         super.onRegister();
      }
   }
}

