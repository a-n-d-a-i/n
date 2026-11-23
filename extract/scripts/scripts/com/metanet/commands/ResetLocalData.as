package com.metanet.commands
{
   import com.metanet.data.EpisodeData;
   import com.metanet.events.MenuEvent;
   import com.metanet.remote.NRequestFactory;
   import com.metanet.remote.NServerConnector;
   import flash.net.SharedObject;
   import org.robotlegs.mvcs.Command;
   
   public class ResetLocalData extends Command
   {
      
      [Inject]
      public var episodes:EpisodeData;
      
      [Inject]
      public var requestFactory:NRequestFactory;
      
      [Inject]
      public var server:NServerConnector;
      
      [Inject]
      public var sharedObject:SharedObject;
      
      public function ResetLocalData()
      {
         super();
      }
      
      override public function execute() : void
      {
         this.server.sendRequest(this.requestFactory.logout());
         this.episodes.clearPlayerData();
         this.sharedObject.clear();
         try
         {
            this.sharedObject.flush();
         }
         catch(e:Error)
         {
         }
         dispatch(new MenuEvent(MenuEvent.STORE_DEFAULTS));
      }
   }
}

