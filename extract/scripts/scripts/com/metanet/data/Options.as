package com.metanet.data
{
   public class Options
   {
      
      public var enteredTerm:String = "";
      
      public var enteredType:String;
      
      public var selectedTerm:String;
      
      public var selectedType:String;
      
      public var volume:Number = 1;
      
      public var coopMode:Boolean;
      
      public var selectedLevel:Level;
      
      public var selectedLevelIndexInSearch:int = -1;
      
      public var selectedEpisode:int = -1;
      
      public var selectedChallenge:int = -1;
      
      public var ticksToResumeWith:int;
      
      public var scoreGoldImmediately:Boolean;
      
      public var resetScoreOnDeath:Boolean;
      
      public var ninjaFlavour:int;
      
      public var p1Colour:uint;
      
      public var p2Colour:uint;
      
      public function Options()
      {
         super();
      }
   }
}

