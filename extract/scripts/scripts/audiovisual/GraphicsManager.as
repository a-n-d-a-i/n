package audiovisual
{
   import audiovisual.entitygraphics.EntityGraphics;
   import audiovisual.entitygraphics.EntityGraphics_Ninja;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.media.SoundMixer;
   import simulation.entities.Entity_Base;
   import simulation.ninja.Ninja;
   
   public class GraphicsManager
   {
      
      private var root:Sprite;
      
      private var entity_gfxList:Vector.<EntityGraphics>;
      
      private var player_gfxList:Vector.<EntityGraphics_Ninja>;
      
      private var tile_mcList:Vector.<MovieClip>;
      
      private var num_rows:int;
      
      private var num_cols:int;
      
      private var particle_buffer_front:Sprite;
      
      private var particle_buffer_back:Sprite;
      
      private var pman:ParticleManager;
      
      public function GraphicsManager(param1:Sprite, param2:Vector.<Entity_Base>, param3:Vector.<Ninja>, param4:Vector.<int>, param5:int, param6:int, param7:Boolean)
      {
         var _loc17_:EntityGraphics = null;
         var _loc18_:EntityGraphics_Ninja = null;
         var _loc19_:int = 0;
         var _loc20_:MovieClip = null;
         var _loc21_:int = 0;
         super();
         this.num_rows = param5;
         this.num_cols = param6;
         this.root = new Sprite();
         param1.addChild(this.root);
         this.entity_gfxList = new Vector.<EntityGraphics>(param2.length,true);
         this.player_gfxList = new Vector.<EntityGraphics_Ninja>(param3.length,true);
         this.tile_mcList = new Vector.<MovieClip>(this.num_rows * this.num_cols,true);
         var _loc8_:Vector.<DisplayObject> = new Vector.<DisplayObject>();
         if(param7)
         {
            this.particle_buffer_back = new Sprite();
            _loc8_.push(this.particle_buffer_back);
         }
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         while(_loc10_ < param2.length)
         {
            _loc17_ = param2[_loc10_].GenerateGraphicComponent();
            if(_loc17_ != null)
            {
               _loc17_.RegisterGraphics(_loc8_);
               this.entity_gfxList[_loc9_] = _loc17_;
               _loc9_++;
            }
            _loc10_++;
         }
         var _loc11_:Vector.<DisplayObject> = new Vector.<DisplayObject>();
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         while(_loc13_ < param3.length)
         {
            _loc18_ = param3[_loc13_].GenerateGraphicComponent();
            if(_loc18_ != null)
            {
               _loc18_.RegisterGraphics(_loc11_);
               this.player_gfxList[_loc12_] = _loc18_;
               _loc12_++;
            }
            _loc13_++;
         }
         var _loc14_:int = int(_loc11_.length - 1);
         while(_loc14_ >= 0)
         {
            _loc8_.push(_loc11_[_loc14_]);
            _loc14_--;
         }
         if(param7)
         {
            this.particle_buffer_front = new Sprite();
            _loc8_.push(this.particle_buffer_front);
         }
         var _loc15_:int = 0;
         while(_loc15_ < this.num_cols)
         {
            _loc19_ = 0;
            while(_loc19_ < this.num_rows)
            {
               _loc20_ = new asset_gfx_tiles();
               _loc20_.x = _loc15_ * 24 + 12;
               _loc20_.y = _loc19_ * 24 + 12;
               _loc21_ = _loc15_ + _loc19_ * this.num_cols;
               _loc20_.gotoAndStop(param4[_loc21_] + 1);
               _loc20_.cacheAsBitmap = true;
               this.tile_mcList[_loc21_] = _loc20_;
               _loc8_.push(_loc20_);
               _loc19_++;
            }
            _loc15_++;
         }
         var _loc16_:int = 0;
         while(_loc16_ < _loc8_.length)
         {
            this.root.addChild(_loc8_[_loc16_]);
            _loc16_++;
         }
         if(param7)
         {
            this.pman = new ParticleManager_Classic(this.particle_buffer_back,this.particle_buffer_front);
         }
         else
         {
            this.pman = new ParticleManager_Null();
         }
      }
      
      public function Hide() : void
      {
         this.root.visible = false;
      }
      
      public function Show() : void
      {
         this.root.visible = true;
      }
      
      public function Clear() : void
      {
         if(this.root.parent != null)
         {
            this.root.parent.removeChild(this.root);
         }
         SoundMixer.stopAll();
      }
      
      public function GetParticleManager() : ParticleManager
      {
         return this.pman;
      }
      
      public function Render() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this.entity_gfxList.length)
         {
            this.entity_gfxList[_loc1_].UpdateState();
            _loc1_++;
         }
         var _loc2_:int = 0;
         while(_loc2_ < this.player_gfxList.length)
         {
            this.player_gfxList[_loc2_].UpdateState();
            _loc2_++;
         }
      }
   }
}

