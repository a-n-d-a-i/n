package assets_fla
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol101")]
   public dynamic class GoldCounter_32 extends MovieClip
   {
      
      public var numgold:TextField;
      
      public function GoldCounter_32()
      {
         super();
         addFrameScript(0,this.frame1);
      }
      
      internal function frame1() : *
      {
         this.stop();
      }
   }
}

