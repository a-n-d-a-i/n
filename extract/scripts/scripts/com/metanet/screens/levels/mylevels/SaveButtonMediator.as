package com.metanet.screens.levels.mylevels
{
   import com.metanet.data.Options;
   import com.metanet.events.SearchEvent;
   import com.metanet.remote.NRequestFactory;
   import com.metanet.remote.NServerConnector;
   import editor.EditorEvent;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import org.robotlegs.mvcs.Mediator;
   
   public class SaveButtonMediator extends Mediator
   {
      
      [Inject]
      public var view:SaveButton;
      
      [Inject]
      public var server:NServerConnector;
      
      [Inject]
      public var requestFactory:NRequestFactory;
      
      [Inject]
      public var options:Options;
      
      public function SaveButtonMediator()
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
      
      private function handleClick(param1:Event) : void
      {
         dispatch(new EditorEvent(EditorEvent.EVENT_SAVE));
      }
   }
}

