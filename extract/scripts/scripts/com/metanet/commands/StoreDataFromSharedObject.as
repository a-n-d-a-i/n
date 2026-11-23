package com.metanet.commands
{
   import com.metanet.data.AccountDetails;
   import com.metanet.data.EpisodeData;
   import com.metanet.data.Options;
   import com.metanet.events.NServerEvent;
   import com.metanet.global.Flavours;
   import com.metanet.global.SavedProperties;
   import com.metanet.ui.GlobalKeys;
   import com.metanet.ui.PlayerKeys;
   import flash.media.SoundMixer;
   import flash.media.SoundTransform;
   import flash.net.SharedObject;
   import org.robotlegs.mvcs.Command;
   
   public class StoreDataFromSharedObject extends Command
   {
      
      [Inject]
      public var so:SharedObject;
      
      [Inject]
      public var account:AccountDetails;
      
      [Inject]
      public var options:Options;
      
      [Inject]
      public var episodes:EpisodeData;
      
      [Inject]
      public var globalKeys:GlobalKeys;
      
      [Inject(name="coop")]
      public var coopKeys:PlayerKeys;
      
      [Inject(name="solo")]
      public var soloKeys:PlayerKeys;
      
      public function StoreDataFromSharedObject()
      {
         super();
      }
      
      override public function execute() : void
      {
         var _loc1_:Array = null;
         var _loc2_:int = 0;
         if(this.so.data[SavedProperties.BEATEN_LEVELS])
         {
            _loc1_ = this.so.data[SavedProperties.BEATEN_LEVELS];
            _loc2_ = 0;
            while(_loc2_ < _loc1_.length)
            {
               if(_loc1_[_loc2_])
               {
                  this.episodes.beatEpisodeFromSharedObject(_loc2_);
               }
               _loc2_++;
            }
         }
         if(this.so.data.hasOwnProperty(SavedProperties.VOLUME))
         {
            this.options.volume = this.so.data[SavedProperties.VOLUME];
            SoundMixer.soundTransform = new SoundTransform(this.options.volume);
         }
         if(this.so.data.hasOwnProperty(SavedProperties.KEY_CONFIG_COOP))
         {
            this.coopKeys.keyConfigString = this.so.data[SavedProperties.KEY_CONFIG_COOP];
         }
         if(this.so.data.hasOwnProperty(SavedProperties.KEY_CONFIG_SOLO))
         {
            this.soloKeys.keyConfigString = this.so.data[SavedProperties.KEY_CONFIG_SOLO];
         }
         if(this.so.data.hasOwnProperty(SavedProperties.MENU_CONFIG_BACK))
         {
            this.globalKeys.back = this.so.data[SavedProperties.MENU_CONFIG_BACK];
         }
         if(this.so.data.hasOwnProperty(SavedProperties.MENU_CONFIG_DOWN))
         {
            this.globalKeys.down = this.so.data[SavedProperties.MENU_CONFIG_DOWN];
         }
         if(this.so.data.hasOwnProperty(SavedProperties.MENU_CONFIG_LEFT))
         {
            this.globalKeys.left = this.so.data[SavedProperties.MENU_CONFIG_LEFT];
         }
         if(this.so.data.hasOwnProperty(SavedProperties.MENU_CONFIG_PAUSE))
         {
            this.globalKeys.pause = this.so.data[SavedProperties.MENU_CONFIG_PAUSE];
         }
         if(this.so.data.hasOwnProperty(SavedProperties.MENU_CONFIG_RIGHT))
         {
            this.globalKeys.right = this.so.data[SavedProperties.MENU_CONFIG_RIGHT];
         }
         if(this.so.data.hasOwnProperty(SavedProperties.MENU_CONFIG_SELECT))
         {
            this.globalKeys.select = this.so.data[SavedProperties.MENU_CONFIG_SELECT];
         }
         if(this.so.data.hasOwnProperty(SavedProperties.MENU_CONFIG_UP))
         {
            this.globalKeys.up = this.so.data[SavedProperties.MENU_CONFIG_UP];
         }
         if(this.so.data.hasOwnProperty(SavedProperties.FLAVOUR))
         {
            this.options.ninjaFlavour = this.so.data[SavedProperties.FLAVOUR];
            this.options.p1Colour = Flavours.getP1Flavour(this.options.ninjaFlavour);
            this.options.p2Colour = Flavours.getP2Flavour(this.options.ninjaFlavour);
         }
         if(Boolean(this.so.data[SavedProperties.COOKIE]) && Boolean(this.so.data[SavedProperties.USER_ID]))
         {
            this.account.loggedIn = true;
            this.account.loggedInUserName = this.so.data[SavedProperties.USERNAME];
            this.account.userID = this.so.data[SavedProperties.USER_ID];
            this.account.cookie = this.so.data[SavedProperties.COOKIE];
            dispatch(new NServerEvent(NServerEvent.READY_TO_SYNC));
         }
      }
   }
}

