package com.metanet.commands
{
   import com.metanet.data.Options;
   import com.metanet.global.Flavours;
   import com.metanet.ui.GlobalKeys;
   import com.metanet.ui.PlayerKeys;
   import flash.media.SoundMixer;
   import flash.media.SoundTransform;
   import flash.ui.Keyboard;
   import org.robotlegs.mvcs.Command;
   
   public class StoreDefaults extends Command
   {
      
      [Inject(name="coop")]
      public var coopKeys:PlayerKeys;
      
      [Inject(name="solo")]
      public var soloKeys:PlayerKeys;
      
      [Inject]
      public var globalKeys:GlobalKeys;
      
      [Inject]
      public var options:Options;
      
      public function StoreDefaults()
      {
         super();
      }
      
      override public function execute() : void
      {
         this.defaultPlayerKeys();
         this.defaultMenuKeys();
         this.defaultOptions();
      }
      
      private function defaultPlayerKeys() : void
      {
         this.soloKeys.bindActionKeyForPlayer(PlayerKeys.JUMP,Keyboard.Z,0);
         this.soloKeys.bindActionKeyForPlayer(PlayerKeys.LEFT,Keyboard.LEFT,0);
         this.soloKeys.bindActionKeyForPlayer(PlayerKeys.RIGHT,Keyboard.RIGHT,0);
         this.soloKeys.bindActionKeyForPlayer(PlayerKeys.SUICIDE,Keyboard.K,0);
         this.coopKeys.bindActionKeyForPlayer(PlayerKeys.JUMP,Keyboard.SHIFT,0);
         this.coopKeys.bindActionKeyForPlayer(PlayerKeys.LEFT,Keyboard.A,0);
         this.coopKeys.bindActionKeyForPlayer(PlayerKeys.RIGHT,Keyboard.D,0);
         this.coopKeys.bindActionKeyForPlayer(PlayerKeys.SUICIDE,Keyboard.T,0);
         this.coopKeys.bindActionKeyForPlayer(PlayerKeys.JUMP,Keyboard.N,1);
         this.coopKeys.bindActionKeyForPlayer(PlayerKeys.LEFT,188,1);
         this.coopKeys.bindActionKeyForPlayer(PlayerKeys.RIGHT,190,1);
         this.coopKeys.bindActionKeyForPlayer(PlayerKeys.SUICIDE,Keyboard.O,1);
      }
      
      private function defaultMenuKeys() : void
      {
         this.globalKeys.up = Keyboard.UP;
         this.globalKeys.down = Keyboard.DOWN;
         this.globalKeys.left = Keyboard.LEFT;
         this.globalKeys.right = Keyboard.RIGHT;
         this.globalKeys.pause = Keyboard.P;
         this.globalKeys.quit = Keyboard.Q;
         this.globalKeys.select = Keyboard.Z;
      }
      
      private function defaultOptions() : void
      {
         this.options.volume = 0.3;
         SoundMixer.soundTransform = new SoundTransform(this.options.volume);
         this.options.ninjaFlavour = 0;
         this.options.p1Colour = Flavours.getP1Flavour(0);
         this.options.p2Colour = Flavours.getP2Flavour(0);
      }
   }
}

