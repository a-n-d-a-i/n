package com.metanet.screens.shared
{
   import com.metanet.data.Options;
   import com.metanet.events.StartEvent;
   import com.metanet.global.SavedProperties;
   import flash.events.MouseEvent;
   import flash.net.SharedObject;
   import org.robotlegs.mvcs.Mediator;
   
   public class ResumeButtonMediator extends Mediator
   {
      
      [Inject]
      public var view:ResumeButton;
      
      [Inject]
      public var sharedObject:SharedObject;
      
      [Inject]
      public var options:Options;
      
      public function ResumeButtonMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         if(!this.sharedObject.data.hasOwnProperty(SavedProperties.SAVED_EPISODE) && !this.sharedObject.data.hasOwnProperty(SavedProperties.SAVED_CHALLENGE))
         {
            this.view.visible = false;
            return;
         }
         addViewListener(MouseEvent.CLICK,this.handleClick);
      }
      
      private function handleClick(param1:MouseEvent) : void
      {
         this.options.selectedLevelIndexInSearch = this.sharedObject.data[SavedProperties.SAVED_LEVEL];
         this.options.ticksToResumeWith = this.sharedObject.data[SavedProperties.SAVED_TICKS_REMAINING];
         if(this.sharedObject.data.hasOwnProperty(SavedProperties.SAVED_EPISODE))
         {
            this.options.selectedEpisode = this.sharedObject.data[SavedProperties.SAVED_EPISODE];
            dispatch(new StartEvent(StartEvent.RESUME_EPISODE));
         }
         else
         {
            this.options.selectedChallenge = this.sharedObject.data[SavedProperties.SAVED_CHALLENGE];
            dispatch(new StartEvent(StartEvent.RESUME_CHALLENGE));
         }
      }
   }
}

