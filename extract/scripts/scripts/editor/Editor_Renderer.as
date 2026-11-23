package editor
{
   import flash.display.Graphics;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import tiles.tiletypes;
   
   public class Editor_Renderer
   {
      
      private var stage:Sprite;
      
      private var buffer_current_tiles:Sprite;
      
      private var buffer_current_entities:Sprite;
      
      private var buffer_selected_tiles_outline:Sprite;
      
      private var buffer_selected_tiles:Sprite;
      
      private var buffer_selected_entities:Sprite;
      
      private var buffer_pairs:Sprite;
      
      private var buffer_grid:Sprite;
      
      private var mcList_tiles_bg:Vector.<MovieClip>;
      
      private var mcList_entities_bg:Vector.<MovieClip>;
      
      private var MAP_ETYPE_TO_STARTFRAME:Vector.<int>;
      
      public function Editor_Renderer(param1:Sprite)
      {
         var _loc5_:MovieClip = null;
         var _loc6_:MovieClip = null;
         var _loc7_:MovieClip = null;
         var _loc8_:MovieClip = null;
         var _loc9_:int = 0;
         var _loc10_:MovieClip = null;
         super();
         this.stage = param1;
         this.buffer_current_tiles = new Sprite();
         this.buffer_current_entities = new Sprite();
         this.buffer_selected_tiles = new Sprite();
         this.buffer_selected_tiles_outline = new Sprite();
         this.buffer_selected_entities = new Sprite();
         this.buffer_grid = new Sprite();
         this.buffer_pairs = new Sprite();
         this.stage.addChild(this.buffer_current_tiles);
         this.stage.addChild(this.buffer_selected_tiles_outline);
         this.stage.addChild(this.buffer_selected_tiles);
         this.stage.addChild(this.buffer_grid);
         this.stage.addChild(this.buffer_current_entities);
         this.stage.addChild(this.buffer_selected_entities);
         this.stage.addChild(this.buffer_pairs);
         this.MAP_ETYPE_TO_STARTFRAME = new Vector.<int>(21,true);
         this.MAP_ETYPE_TO_STARTFRAME[edat.ETYPE_PLAYER] = 45;
         this.MAP_ETYPE_TO_STARTFRAME[edat.ETYPE_MINE] = 54;
         this.MAP_ETYPE_TO_STARTFRAME[edat.ETYPE_GOLD] = 95;
         this.MAP_ETYPE_TO_STARTFRAME[edat.ETYPE_DOOR_REGULAR] = 107;
         this.MAP_ETYPE_TO_STARTFRAME[edat.ETYPE_DOOR_LOCKED] = 115;
         this.MAP_ETYPE_TO_STARTFRAME[edat.ETYPE_SWITCH_LOCKED] = 43;
         this.MAP_ETYPE_TO_STARTFRAME[edat.ETYPE_DOOR_TRAP] = 99;
         this.MAP_ETYPE_TO_STARTFRAME[edat.ETYPE_SWITCH_TRAP] = 42;
         this.MAP_ETYPE_TO_STARTFRAME[edat.ETYPE_ONEWAY] = 46;
         this.MAP_ETYPE_TO_STARTFRAME[edat.ETYPE_EXIT_DOOR] = 98;
         this.MAP_ETYPE_TO_STARTFRAME[edat.ETYPE_EXIT_SWITCH] = 97;
         this.MAP_ETYPE_TO_STARTFRAME[edat.ETYPE_CHAINGUN] = 155;
         this.MAP_ETYPE_TO_STARTFRAME[edat.ETYPE_LASER] = 63;
         this.MAP_ETYPE_TO_STARTFRAME[edat.ETYPE_ZAP] = 1;
         this.MAP_ETYPE_TO_STARTFRAME[edat.ETYPE_CHASER] = 123;
         this.MAP_ETYPE_TO_STARTFRAME[edat.ETYPE_FLOORGUARD] = 96;
         this.MAP_ETYPE_TO_STARTFRAME[edat.ETYPE_LAUNCHPAD] = 55;
         this.MAP_ETYPE_TO_STARTFRAME[edat.ETYPE_BOUNCEBLOCK] = 187;
         this.MAP_ETYPE_TO_STARTFRAME[edat.ETYPE_ROCKET] = 44;
         this.MAP_ETYPE_TO_STARTFRAME[edat.ETYPE_TURRET] = 33;
         this.MAP_ETYPE_TO_STARTFRAME[edat.ETYPE_THWOMP] = 34;
         this.mcList_entities_bg = new Vector.<MovieClip>();
         var _loc2_:int = 0;
         while(_loc2_ < edat.num_cols + 2)
         {
            _loc5_ = new asset_gfx_tiles();
            _loc6_ = new asset_gfx_tiles();
            _loc5_.x = (_loc2_ + 0.5) * edat.cell_size;
            _loc5_.y = 0.5 * edat.cell_size;
            _loc6_.x = (_loc2_ + 0.5) * edat.cell_size;
            _loc6_.y = (edat.num_rows + 1 + 0.5) * edat.cell_size;
            _loc5_.gotoAndStop(2);
            _loc6_.gotoAndStop(2);
            _loc5_.cacheAsBitmap = true;
            _loc6_.cacheAsBitmap = true;
            this.buffer_current_tiles.addChild(_loc5_);
            this.buffer_current_tiles.addChild(_loc6_);
            _loc2_++;
         }
         var _loc3_:int = 0;
         while(_loc3_ < edat.num_rows)
         {
            _loc7_ = new asset_gfx_tiles();
            _loc8_ = new asset_gfx_tiles();
            _loc7_.x = 0.5 * edat.cell_size;
            _loc7_.y = (_loc3_ + 1.5) * edat.cell_size;
            _loc8_.x = (edat.num_cols + 1 + 0.5) * edat.cell_size;
            _loc8_.y = (_loc3_ + 1.5) * edat.cell_size;
            _loc7_.gotoAndStop(2);
            _loc8_.gotoAndStop(2);
            _loc7_.cacheAsBitmap = true;
            _loc8_.cacheAsBitmap = true;
            this.buffer_current_tiles.addChild(_loc7_);
            this.buffer_current_tiles.addChild(_loc8_);
            _loc3_++;
         }
         this.mcList_tiles_bg = new Vector.<MovieClip>(edat.num_cols * edat.num_rows,true);
         var _loc4_:int = 0;
         while(_loc4_ < edat.num_cols)
         {
            _loc9_ = 0;
            while(_loc9_ < edat.num_rows)
            {
               _loc10_ = new asset_gfx_tiles();
               _loc10_.x = (_loc4_ + 1.5) * edat.cell_size;
               _loc10_.y = (_loc9_ + 1.5) * edat.cell_size;
               _loc10_.gotoAndStop(1);
               _loc10_.cacheAsBitmap = true;
               this.buffer_current_tiles.addChild(_loc10_);
               this.mcList_tiles_bg[_loc4_ + _loc9_ * edat.num_cols] = _loc10_;
               _loc9_++;
            }
            _loc4_++;
         }
      }
      
      public function Clear() : void
      {
         while(this.buffer_selected_tiles.numChildren > 0)
         {
            this.buffer_selected_tiles.removeChildAt(0);
         }
         while(this.buffer_selected_tiles_outline.numChildren > 0)
         {
            this.buffer_selected_tiles_outline.removeChildAt(0);
         }
         while(this.buffer_selected_entities.numChildren > 0)
         {
            this.buffer_selected_entities.removeChildAt(0);
         }
         this.buffer_grid.graphics.clear();
         this.buffer_pairs.graphics.clear();
      }
      
      public function Show() : void
      {
         this.stage.visible = true;
      }
      
      public function Hide() : void
      {
         this.stage.visible = false;
      }
      
      public function StartFrame() : void
      {
         this.Clear();
         this.buffer_current_tiles.alpha = 1;
         this.buffer_current_entities.alpha = 1;
      }
      
      public function DrawCell(param1:uint, param2:uint, param3:uint) : void
      {
         var _loc4_:Graphics = this.buffer_grid.graphics;
         _loc4_.lineStyle(0,0,0.3);
         _loc4_.moveTo(param1 * param3,param2 * param3);
         _loc4_.lineTo((param1 + 1) * param3,param2 * param3);
         _loc4_.lineTo((param1 + 1) * param3,(param2 + 1) * param3);
         _loc4_.lineTo(param1 * param3,(param2 + 1) * param3);
         _loc4_.lineTo(param1 * param3,param2 * param3);
      }
      
      public function DrawPair(param1:Number, param2:Number, param3:Number, param4:Number) : void
      {
         var _loc5_:Graphics = this.buffer_pairs.graphics;
         _loc5_.lineStyle(0,16777215,0.5);
         _loc5_.moveTo(param1,param2);
         _loc5_.lineTo(param3,param4);
      }
      
      public function DrawSnapGrid(param1:uint, param2:uint, param3:uint, param4:uint, param5:uint, param6:Boolean) : void
      {
         var _loc15_:Number = NaN;
         var _loc16_:int = 0;
         var _loc17_:int = 0;
         var _loc7_:Graphics = this.buffer_grid.graphics;
         var _loc8_:Number = param3;
         var _loc9_:Number = param3;
         var _loc10_:Number = (param1 + 1) * param3;
         var _loc11_:Number = (param2 + 1) * param3;
         var _loc12_:Number = param3 / param4;
         var _loc13_:Number = param3 / param5;
         _loc7_.lineStyle(0,0,0.04);
         var _loc14_:int = 0;
         while(_loc14_ < param1 * param4)
         {
            _loc7_.moveTo(_loc8_ + _loc14_ * _loc12_,_loc9_);
            _loc7_.lineTo(_loc8_ + _loc14_ * _loc12_,_loc11_);
            _loc14_++;
         }
         if(param6)
         {
            _loc15_ = param3 / 4;
            _loc16_ = 0;
            while(_loc16_ < param2 * param5 - 1)
            {
               _loc7_.moveTo(_loc8_,_loc9_ + _loc16_ * _loc13_ + _loc15_);
               _loc7_.lineTo(_loc10_,_loc9_ + _loc16_ * _loc13_ + _loc15_);
               _loc16_++;
            }
         }
         else
         {
            _loc17_ = 0;
            while(_loc17_ < param2 * param5)
            {
               _loc7_.moveTo(_loc8_,_loc9_ + _loc17_ * _loc13_);
               _loc7_.lineTo(_loc10_,_loc9_ + _loc17_ * _loc13_);
               _loc17_++;
            }
         }
      }
      
      public function DrawGrid(param1:uint, param2:uint, param3:uint, param4:uint) : void
      {
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         if(param4 == 0)
         {
            return;
         }
         var _loc5_:Graphics = this.buffer_grid.graphics;
         var _loc6_:Number = param3;
         var _loc7_:Number = param3;
         var _loc8_:Number = (param1 + 1) * param3;
         var _loc9_:Number = (param2 + 1) * param3;
         _loc5_.lineStyle(0,0,0.1);
         var _loc10_:int = 0;
         while(_loc10_ < param1)
         {
            if(param4 == 3)
            {
               if(_loc10_ % 2 == 0)
               {
                  _loc5_.lineStyle(0,0,0.08);
               }
               else
               {
                  _loc5_.lineStyle(0,16777215,0.15);
               }
            }
            _loc5_.moveTo(_loc6_ + _loc10_ * param3,_loc7_);
            _loc5_.lineTo(_loc6_ + _loc10_ * param3,_loc9_);
            _loc10_++;
         }
         var _loc11_:int = 0;
         while(_loc11_ < param2)
         {
            if(param4 == 3)
            {
               if(_loc11_ % 2 == 0)
               {
                  _loc5_.lineStyle(0,0,0.08);
               }
               else
               {
                  _loc5_.lineStyle(0,16777215,0.15);
               }
            }
            _loc5_.moveTo(_loc6_,_loc7_ + _loc11_ * param3);
            _loc5_.lineTo(_loc8_,_loc7_ + _loc11_ * param3);
            _loc11_++;
         }
         if(param4 == 2)
         {
            _loc12_ = Math.floor(Number(param1 + 1) / 2);
            _loc13_ = Math.floor(Number(param2 + 1) / 2);
            _loc5_.lineStyle(0,16777215,0.5);
            _loc5_.moveTo(_loc12_ * param3,_loc7_);
            _loc5_.lineTo(_loc12_ * param3,_loc9_);
            _loc5_.moveTo((_loc12_ + 1) * param3,_loc7_);
            _loc5_.lineTo((_loc12_ + 1) * param3,_loc9_);
            _loc5_.moveTo(_loc6_,_loc13_ * param3);
            _loc5_.lineTo(_loc8_,_loc13_ * param3);
            _loc5_.moveTo(_loc6_,(_loc13_ + 1) * param3);
            _loc5_.lineTo(_loc8_,(_loc13_ + 1) * param3);
         }
      }
      
      public function DrawTiles_Background(param1:Vector.<uint>) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < param1.length)
         {
            this.mcList_tiles_bg[_loc2_].gotoAndStop(param1[_loc2_] + 1);
            _loc2_++;
         }
      }
      
      public function DrawTiles_Selected(param1:TileRect, param2:int, param3:int, param4:Boolean) : void
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:MovieClip = null;
         var _loc9_:MovieClip = null;
         this.buffer_current_tiles.alpha = 0.5;
         this.buffer_current_entities.alpha = 0.5;
         if(param1 != null)
         {
            _loc5_ = 0;
            while(_loc5_ < param1.stride)
            {
               _loc6_ = 0;
               while(_loc6_ < param1.GetNumRows())
               {
                  _loc7_ = _loc5_ + _loc6_ * param1.stride;
                  if(!(param1.data[_loc7_] == tiletypes.EMPTY && !param4))
                  {
                     _loc8_ = new asset_editor_gfx_tiles_opaque();
                     _loc8_.x = (param2 + _loc5_ + 0.5) * edat.cell_size;
                     _loc8_.y = (param3 + _loc6_ + 0.5) * edat.cell_size;
                     _loc8_.gotoAndStop(param1.data[_loc7_] + 1);
                     this.buffer_selected_tiles.addChild(_loc8_);
                     _loc9_ = new asset_editor_gfx_tiles_highlight();
                     _loc9_.x = _loc8_.x;
                     _loc9_.y = _loc8_.y;
                     _loc9_.gotoAndStop(1);
                     this.buffer_selected_tiles_outline.addChild(_loc9_);
                  }
                  _loc6_++;
               }
               _loc5_++;
            }
         }
      }
      
      public function DrawEntities_Background(param1:Vector.<Vector.<uint>>) : void
      {
         var _loc3_:MovieClip = null;
         var _loc4_:Vector.<uint> = null;
         var _loc5_:MovieClip = null;
         var _loc6_:int = 0;
         while(this.mcList_entities_bg.length < param1.length)
         {
            _loc3_ = new asset_editor_gfx_master_entity_mc();
            _loc3_.cacheAsBitmap = true;
            this.mcList_entities_bg.push(_loc3_);
            this.buffer_current_entities.addChild(_loc3_);
         }
         var _loc2_:int = 0;
         while(_loc2_ < param1.length)
         {
            _loc4_ = param1[_loc2_];
            if(_loc4_[edat.EPROP_TYPE] != edat.ETYPE_NULLFLAG)
            {
               _loc5_ = this.mcList_entities_bg[_loc2_];
               _loc5_.visible = true;
               _loc6_ = this.MAP_ETYPE_TO_STARTFRAME[_loc4_[edat.EPROP_TYPE]];
               _loc5_.x = edat.quantize_step_size * _loc4_[edat.EPROP_X];
               _loc5_.y = edat.quantize_step_size * _loc4_[edat.EPROP_Y];
               if(_loc4_.length > 3)
               {
                  if(_loc4_.length > 4)
                  {
                     _loc5_.gotoAndStop(_loc6_ + _loc4_[edat.EPROP_DIR] * 4 + _loc4_[edat.EPROP_MOVE]);
                  }
                  else
                  {
                     _loc5_.gotoAndStop(_loc6_ + _loc4_[edat.EPROP_DIR]);
                  }
               }
               else
               {
                  _loc5_.gotoAndStop(_loc6_);
               }
            }
            _loc2_++;
         }
         while(_loc2_ < this.mcList_entities_bg.length)
         {
            this.mcList_entities_bg[_loc2_].visible = false;
            _loc2_++;
         }
      }
      
      public function DrawEntity_Preview(param1:uint, param2:uint, param3:uint, param4:uint, param5:uint, param6:Boolean, param7:Boolean) : void
      {
         var _loc8_:MovieClip = new edat.MAP_ETYPE_TO_MC[param1]();
         _loc8_.x = edat.quantize_step_size * param2;
         _loc8_.y = edat.quantize_step_size * param3;
         if(param6)
         {
            if(param7)
            {
               _loc8_.gotoAndStop(1 + param4 * 4 + param5);
            }
            else
            {
               _loc8_.gotoAndStop(1 + param4);
            }
         }
         else
         {
            _loc8_.gotoAndStop(1);
         }
         _loc8_.alpha = 0.5;
         this.buffer_selected_entities.addChild(_loc8_);
      }
      
      public function DrawEntities_Selected(param1:Vector.<Vector.<uint>>, param2:int, param3:int) : void
      {
         var _loc5_:Vector.<uint> = null;
         var _loc6_:MovieClip = null;
         var _loc4_:int = 0;
         while(_loc4_ < param1.length)
         {
            _loc5_ = param1[_loc4_];
            _loc6_ = new edat.MAP_ETYPE_TO_MC_SELECTED[_loc5_[edat.EPROP_TYPE]]();
            _loc6_.x = edat.quantize_step_size * _loc5_[edat.EPROP_X] + param2 * edat.cell_size;
            _loc6_.y = edat.quantize_step_size * _loc5_[edat.EPROP_Y] + param3 * edat.cell_size;
            if(_loc5_.length > 3)
            {
               if(_loc5_.length > 4)
               {
                  _loc6_.gotoAndStop(1 + _loc5_[edat.EPROP_DIR] * 4 + _loc5_[edat.EPROP_MOVE]);
               }
               else
               {
                  _loc6_.gotoAndStop(1 + _loc5_[edat.EPROP_DIR]);
               }
            }
            else
            {
               _loc6_.gotoAndStop(1);
            }
            this.buffer_selected_entities.addChild(_loc6_);
            _loc4_++;
         }
      }
   }
}

