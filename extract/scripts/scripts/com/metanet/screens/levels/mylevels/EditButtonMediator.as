package com.metanet.screens.levels.mylevels
{
   import com.metanet.data.Options;
   import com.metanet.events.SearchEvent;
   import com.metanet.events.StartEvent;
   import flash.events.MouseEvent;
   import org.robotlegs.mvcs.Mediator;
   
   public class EditButtonMediator extends Mediator
   {
      
      [Inject]
      public var view:EditButton;
      
      [Inject]
      public var options:Options;
      
      public function EditButtonMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         addViewListener(MouseEvent.CLICK,this.handleClick);
         addContextListener(SearchEvent.SELECT_LEVEL,this.handleLevelSelected);
      }
      
      private function handleLevelSelected(param1:SearchEvent) : void
      {
         if(this.options.selectedLevel.data)
         {
            this.view.visible = true;
         }
         else
         {
            this.view.visible = false;
         }
      }
      
      private function handleClick(param1:MouseEvent) : void
      {
         dispatch(new StartEvent(StartEvent.START_EDITOR));
      }
   }
}

