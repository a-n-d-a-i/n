package com.metanet.screens.levels.userlevels
{
   public class Rate3Mediator extends RatingMediator
   {
      
      [Inject]
      public var view:Rate3Button;
      
      public function Rate3Mediator()
      {
         super();
         _rating = 3;
      }
      
      override public function onRegister() : void
      {
         _view = this.view;
         super.onRegister();
      }
   }
}

