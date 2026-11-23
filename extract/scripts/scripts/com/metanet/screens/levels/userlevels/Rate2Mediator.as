package com.metanet.screens.levels.userlevels
{
   public class Rate2Mediator extends RatingMediator
   {
      
      [Inject]
      public var view:Rate2Button;
      
      public function Rate2Mediator()
      {
         super();
         _rating = 2;
      }
      
      override public function onRegister() : void
      {
         _view = this.view;
         super.onRegister();
      }
   }
}

