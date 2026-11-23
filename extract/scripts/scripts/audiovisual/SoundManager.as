package audiovisual
{
   import flash.display.MovieClip;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.media.SoundTransform;
   
   public class SoundManager
   {
      
      private var gold_snd:Sound;
      
      private var gold_channels:Vector.<SoundChannel>;
      
      private var gold_oldest:int;
      
      private var gold_triggered:Boolean;
      
      private var mc_gold:MovieClip;
      
      private var mc_ragdoll:MovieClip;
      
      public function SoundManager()
      {
         super();
         this.mc_ragdoll = new asset_sfx_ragdollMC();
         this.gold_snd = new asset_sfx_gold();
         this.gold_channels = new Vector.<SoundChannel>(2,true);
         var _loc1_:int = 0;
         while(_loc1_ < this.gold_channels.length)
         {
            this.gold_channels[_loc1_] = new SoundChannel();
            _loc1_++;
         }
         this.gold_oldest = 0;
         this.gold_triggered = false;
      }
      
      public function Tick() : void
      {
         this.gold_triggered = false;
      }
      
      public function PlaySound_Gold() : void
      {
         var _loc1_:SoundTransform = null;
         if(!this.gold_triggered)
         {
            this.gold_triggered = true;
            this.gold_channels[this.gold_oldest].stop();
            _loc1_ = new SoundTransform(0.25,0);
            this.gold_channels[this.gold_oldest] = this.gold_snd.play(0,0,_loc1_);
            this.gold_oldest = (this.gold_oldest + 1) % this.gold_channels.length;
         }
      }
      
      public function PlaySound_Ragdoll(param1:String) : void
      {
         this.mc_ragdoll.gotoAndPlay(param1);
      }
   }
}

