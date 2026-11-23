package
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol150")]
   public dynamic class MetanetLevelDisplay extends MovieClip
   {
      
      public var unfavourite:UnfavouriteButton;
      
      public var autoLaunch:TextField;
      
      public var loadingHighscores:MovieClip;
      
      public var levelName:TextField;
      
      public var favourite:FavouriteButton;
      
      public function MetanetLevelDisplay()
      {
         super();
      }
   }
}

