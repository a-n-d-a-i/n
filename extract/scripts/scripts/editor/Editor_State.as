package editor
{
   import flash.utils.ByteArray;
   import tiles.tiletypes;
   
   public class Editor_State
   {
      
      public var tileIDs:Vector.<uint>;
      
      public var entities:Vector.<Vector.<uint>>;
      
      public function Editor_State()
      {
         super();
         var _loc1_:int = edat.num_cols * edat.num_rows;
         this.tileIDs = new Vector.<uint>(_loc1_,true);
         this.entities = new Vector.<Vector.<uint>>();
      }
      
      public static function Load_From_Bytes(param1:ByteArray) : Editor_State
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:Vector.<uint> = null;
         var _loc12_:Vector.<uint> = null;
         var _loc13_:int = 0;
         var _loc2_:Editor_State = new Editor_State();
         param1.position = 0;
         param1.readUnsignedByte();
         param1.readUnsignedByte();
         param1.readUnsignedByte();
         param1.readUnsignedByte();
         if(param1.bytesAvailable < _loc2_.tileIDs.length)
         {
            trace("WARNING! Someone passed Load_From_Bytes() a bunch of bullshit; we didn\'t load it.");
            return new Editor_State();
         }
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_.tileIDs.length)
         {
            _loc2_.tileIDs[_loc3_] = param1.readUnsignedByte();
            _loc3_++;
         }
         var _loc4_:uint = 0;
         while(_loc4_ < edat.num_structtypes)
         {
            if(param1.bytesAvailable < 2)
            {
               trace("WARNING! Someone passed Load_From_Bytes() a bunch of bullshit; we didn\'t load it.");
               return new Editor_State();
            }
            _loc5_ = param1.readShort();
            _loc6_ = int(param1.position);
            _loc7_ = 0;
            while(_loc7_ < _loc5_)
            {
               _loc11_ = new Vector.<uint>();
               _loc2_.entities.push(_loc11_);
               _loc11_.push(edat.MAP_STRUCT_TO_ETYPE[_loc4_]);
               _loc12_ = new Vector.<uint>();
               if(_loc4_ == edat.STRUCTTYPE_EXIT)
               {
                  _loc2_.entities.push(_loc12_);
                  _loc12_.push(edat.ETYPE_EXIT_SWITCH);
                  if(param1.bytesAvailable < 4)
                  {
                     trace("WARNING! Someone passed Load_From_Bytes() a bunch of bullshit; we didn\'t load it.");
                     return new Editor_State();
                  }
                  _loc11_.push(param1.readUnsignedByte());
                  _loc11_.push(param1.readUnsignedByte());
                  _loc12_.push(param1.readUnsignedByte());
                  _loc12_.push(param1.readUnsignedByte());
               }
               else if(_loc4_ == edat.STRUCTTYPE_DOOR_LOCKED)
               {
                  _loc2_.entities.push(_loc12_);
                  _loc12_.push(edat.ETYPE_SWITCH_LOCKED);
                  if(param1.bytesAvailable < 5)
                  {
                     trace("WARNING! Someone passed Load_From_Bytes() a bunch of bullshit; we didn\'t load it.");
                     return new Editor_State();
                  }
                  _loc11_.push(param1.readUnsignedByte());
                  _loc11_.push(param1.readUnsignedByte());
                  _loc11_.push(param1.readUnsignedByte());
                  _loc12_.push(param1.readUnsignedByte());
                  _loc12_.push(param1.readUnsignedByte());
               }
               else if(_loc4_ == edat.STRUCTTYPE_DOOR_TRAP)
               {
                  _loc2_.entities.push(_loc12_);
                  _loc12_.push(edat.ETYPE_SWITCH_TRAP);
                  if(param1.bytesAvailable < 5)
                  {
                     trace("WARNING! Someone passed Load_From_Bytes() a bunch of bullshit; we didn\'t load it.");
                     return new Editor_State();
                  }
                  _loc11_.push(param1.readUnsignedByte());
                  _loc11_.push(param1.readUnsignedByte());
                  _loc11_.push(param1.readUnsignedByte());
                  _loc12_.push(param1.readUnsignedByte());
                  _loc12_.push(param1.readUnsignedByte());
               }
               else
               {
                  if(param1.bytesAvailable < edat.STRUCT_SIZE[_loc4_])
                  {
                     trace("WARNING! Someone passed Load_From_Bytes() a bunch of bullshit; we didn\'t load it.");
                     return new Editor_State();
                  }
                  _loc13_ = 0;
                  while(_loc13_ < edat.STRUCT_SIZE[_loc4_])
                  {
                     _loc11_.push(param1.readUnsignedByte());
                     _loc13_++;
                  }
               }
               _loc7_++;
            }
            _loc8_ = int(param1.position);
            _loc9_ = _loc8_ - _loc6_;
            _loc10_ = _loc5_ * edat.STRUCT_SIZE[_loc4_];
            if(_loc9_ != _loc10_)
            {
               trace("WARNING! Editor_State.Load_From_Bytes() read the wrong number of bytes: " + _loc9_ + " , " + _loc10_);
            }
            _loc4_++;
         }
         return _loc2_;
      }
      
      public static function Save_To_Bytes(param1:Editor_State) : ByteArray
      {
         var _loc10_:Vector.<uint> = null;
         var _loc11_:uint = 0;
         var _loc12_:int = 0;
         var _loc13_:Vector.<uint> = null;
         var _loc14_:int = 0;
         var _loc15_:Vector.<uint> = null;
         var _loc16_:int = 0;
         var _loc17_:int = 0;
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.position = 0;
         _loc2_.writeByte(0);
         _loc2_.writeByte(0);
         _loc2_.writeByte(0);
         _loc2_.writeByte(0);
         var _loc3_:int = 0;
         while(_loc3_ < param1.tileIDs.length)
         {
            _loc2_.writeByte(param1.tileIDs[_loc3_]);
            _loc3_++;
         }
         var _loc4_:Vector.<Vector.<uint>> = new Vector.<Vector.<uint>>(edat.num_etypes,true);
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_.length)
         {
            _loc4_[_loc5_] = new Vector.<uint>();
            _loc5_++;
         }
         var _loc6_:int = 0;
         while(_loc6_ < param1.entities.length)
         {
            _loc10_ = param1.entities[_loc6_];
            _loc11_ = _loc10_[0];
            _loc12_ = 1;
            while(_loc12_ < _loc10_.length)
            {
               _loc4_[_loc11_].push(_loc10_[_loc12_]);
               _loc12_++;
            }
            if(_loc11_ == edat.ETYPE_EXIT_DOOR || _loc11_ == edat.ETYPE_DOOR_LOCKED || _loc11_ == edat.ETYPE_DOOR_TRAP)
            {
               if(_loc6_ == param1.entities.length - 1)
               {
                  trace("WARNING! Editor_State.Save_To_Bytes() found a door at the end of the elist, with no switch!");
                  break;
               }
               _loc13_ = param1.entities[_loc6_ + 1];
               _loc14_ = 1;
               while(_loc14_ < _loc13_.length)
               {
                  _loc4_[_loc11_].push(_loc13_[_loc14_]);
                  _loc14_++;
               }
               _loc6_++;
            }
            _loc6_++;
         }
         var _loc7_:Vector.<Vector.<uint>> = new Vector.<Vector.<uint>>(edat.num_structtypes,true);
         var _loc8_:int = 0;
         while(_loc8_ < _loc7_.length)
         {
            _loc7_[_loc8_] = _loc4_[edat.MAP_STRUCT_TO_ETYPE[_loc8_]];
            _loc8_++;
         }
         var _loc9_:int = 0;
         while(_loc9_ < _loc7_.length)
         {
            _loc15_ = _loc7_[_loc9_];
            if(_loc15_.length % edat.STRUCT_SIZE[_loc9_] != 0)
            {
               trace("WARNING! Editor_State.Save_To_Bytes() has a property list with incorrect stride/size; type: " + _loc9_ + ", bytes:" + _loc15_.length);
               _loc2_.writeShort(0);
               break;
            }
            _loc16_ = _loc15_.length / edat.STRUCT_SIZE[_loc9_];
            _loc2_.writeShort(_loc16_);
            _loc17_ = 0;
            while(_loc17_ < _loc15_.length)
            {
               _loc2_.writeByte(_loc15_[_loc17_]);
               _loc17_++;
            }
            if(_loc16_ * edat.STRUCT_SIZE[_loc9_] != _loc15_.length)
            {
               trace("WARNING! Editor_State.Save_To_Bytes() is going crazy: " + _loc16_ + "*" + edat.STRUCT_SIZE[_loc9_] + " != " + _loc15_.length + "?!");
               break;
            }
            _loc9_++;
         }
         return _loc2_;
      }
      
      public function Clone() : Editor_State
      {
         var _loc4_:Vector.<uint> = null;
         var _loc5_:Vector.<uint> = null;
         var _loc6_:int = 0;
         var _loc1_:Editor_State = new Editor_State();
         var _loc2_:int = 0;
         while(_loc2_ < this.tileIDs.length)
         {
            _loc1_.tileIDs[_loc2_] = this.tileIDs[_loc2_];
            _loc2_++;
         }
         var _loc3_:int = 0;
         while(_loc3_ < this.entities.length)
         {
            _loc4_ = this.entities[_loc3_];
            _loc5_ = new Vector.<uint>(_loc4_.length,true);
            _loc6_ = 0;
            while(_loc6_ < _loc4_.length)
            {
               _loc5_[_loc6_] = _loc4_[_loc6_];
               _loc6_++;
            }
            _loc1_.entities[_loc3_] = _loc5_;
            _loc3_++;
         }
         return _loc1_;
      }
      
      public function GetDebugString() : String
      {
         var _loc6_:String = null;
         var _loc7_:int = 0;
         var _loc8_:String = null;
         var _loc9_:* = null;
         var _loc10_:String = null;
         var _loc11_:String = null;
         var _loc1_:* = "Editor State Dump\n";
         var _loc2_:* = "";
         var _loc3_:int = 0;
         while(_loc3_ < edat.num_rows)
         {
            _loc6_ = "";
            _loc7_ = 0;
            while(_loc7_ < edat.num_cols)
            {
               _loc6_ += tiletypes.GetDebugCharFromID(this.tileIDs[_loc7_ + _loc3_ * edat.num_cols]);
               _loc7_++;
            }
            _loc2_ += _loc6_;
            _loc2_ += "\n";
            _loc3_++;
         }
         _loc1_ += "grid:\n";
         _loc1_ += _loc2_;
         var _loc4_:* = "";
         var _loc5_:int = 0;
         while(_loc5_ < this.entities.length)
         {
            _loc8_ = _loc5_.toString();
            while(_loc8_.length < 4)
            {
               _loc8_ = "0" + _loc8_;
            }
            _loc9_ = _loc8_ + " : ";
            if(this.entities[_loc5_][0] < 10)
            {
               _loc9_ += "0" + this.entities[_loc5_][0].toString() + " ";
            }
            else
            {
               _loc9_ += this.entities[_loc5_][0].toString() + " ";
            }
            _loc10_ = this.entities[_loc5_][1].toString();
            while(_loc10_.length < 3)
            {
               _loc10_ = "0" + _loc10_;
            }
            _loc11_ = this.entities[_loc5_][2].toString();
            while(_loc11_.length < 3)
            {
               _loc11_ = "0" + _loc11_;
            }
            _loc9_ += _loc10_ + "," + _loc11_ + " ";
            if(this.entities[_loc5_].length > 3)
            {
               _loc9_ += this.entities[_loc5_][3].toString() + " ";
               if(this.entities[_loc5_].length > 4)
               {
                  _loc9_ += this.entities[_loc5_][4].toString() + " ";
               }
            }
            _loc4_ += _loc9_;
            _loc4_ = _loc4_ + "\n";
            _loc5_++;
         }
         _loc1_ += "entities: " + this.entities.length + "\n";
         return _loc1_ + _loc4_;
      }
   }
}

