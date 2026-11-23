package simulation.ninja
{
   import audiovisual.entitygraphics.EntityGraphics_Ninja;
   import math.mathutils;
   import math.vec2;
   import simpleFramework.SimpleRenderer;
   import simulation.Simulator;
   import simulation.collision.colutils;
   import simulation.entities.Entity_Base;
   import simulation.entities.Entity_Drone_Zap;
   import simulation.entities.Entity_FloorGuard;
   import simulation.entities.Entity_Mine;
   import simulation.entities.Entity_Thwomp;
   import simulation.entities.collision_result_logical;
   import simulation.entities.collision_result_physical;
   
   public class Ragdoll
   {
      
      private static const pRadius:Vector.<Number> = new Vector.<Number>(6,true);
      
      private static const pDrag:Vector.<Number> = new Vector.<Number>(6,true);
      
      private static const sWeight:Vector.<Number> = new Vector.<Number>(5,true);
      
      private static const sMinRatio:Vector.<Number> = new Vector.<Number>(5,true);
      
      private static const hacky_scale:Number = 0.2;
      
      private static const sMaxLen:Vector.<Number> = new Vector.<Number>(5,true);
      
      private static const debugpose_pos:Vector.<vec2> = new Vector.<vec2>(6,true);
      
      private static const debugpose_vel:Vector.<vec2> = new Vector.<vec2>(6,true);
      
      private static const STATE_UNEXPLODED:int = 0;
      
      private static const STATE_EXPLODED:int = 1;
      
      pRadius[0] = 2.49;
      pRadius[1] = 2.49;
      pRadius[2] = 1.99;
      pRadius[3] = 1.99;
      pRadius[4] = 2.99;
      pRadius[5] = 2.99;
      pDrag[0] = 0.99;
      pDrag[1] = 0.995;
      pDrag[2] = 0.995;
      pDrag[3] = 0.99;
      pDrag[4] = 0.99;
      pDrag[5] = 0.995;
      sWeight[0] = 0.4;
      sWeight[1] = 0.2;
      sWeight[2] = 0.26;
      sWeight[3] = 0.32;
      sWeight[4] = 0.37;
      sMinRatio[0] = 0.8;
      sMinRatio[1] = 0.6;
      sMinRatio[2] = 0.6;
      sMinRatio[3] = 0.6;
      sMinRatio[4] = 0.6;
      sMaxLen[0] = 30 * hacky_scale;
      sMaxLen[1] = 40 * hacky_scale;
      sMaxLen[2] = 40 * hacky_scale;
      sMaxLen[3] = 60 * hacky_scale;
      sMaxLen[4] = 60 * hacky_scale;
      debugpose_pos[0] = new vec2(0,-sMaxLen[0]);
      debugpose_pos[1] = new vec2(0,0);
      debugpose_pos[2] = new vec2(sMaxLen[1],debugpose_pos[0].y);
      debugpose_pos[3] = new vec2(-sMaxLen[2],debugpose_pos[0].y);
      debugpose_pos[4] = new vec2(Math.SQRT1_2 * sMaxLen[3],Math.SQRT1_2 * sMaxLen[3]);
      debugpose_pos[5] = new vec2(Math.SQRT1_2 * -sMaxLen[4],Math.SQRT1_2 * sMaxLen[3]);
      debugpose_vel[0] = new vec2(0,0);
      debugpose_vel[1] = new vec2(0,0);
      debugpose_vel[2] = new vec2(0,0);
      debugpose_vel[3] = new vec2(0,0);
      debugpose_vel[4] = new vec2(0,0);
      debugpose_vel[5] = new vec2(0,0);
      
      private var cur_state:int;
      
      private var explosion_accumulator:Number = 0;
      
      private var pList:Vector.<Vector.<RagParticle>>;
      
      private var sList:Vector.<Vector.<RagStick>>;
      
      private var objList:Vector.<Entity_Base>;
      
      private var result_logical:collision_result_logical;
      
      private var result_physical:collision_result_physical;
      
      private var cp:vec2;
      
      public function Ragdoll()
      {
         super();
         this.cur_state = STATE_UNEXPLODED;
         this.explosion_accumulator = 0;
         this.pList = new Vector.<Vector.<RagParticle>>(2,true);
         this.pList[STATE_UNEXPLODED] = new Vector.<RagParticle>(6,true);
         this.pList[STATE_UNEXPLODED][0] = new RagParticle(pRadius[0],pDrag[0]);
         this.pList[STATE_UNEXPLODED][1] = new RagParticle(pRadius[1],pDrag[1]);
         this.pList[STATE_UNEXPLODED][2] = new RagParticle(pRadius[2],pDrag[2]);
         this.pList[STATE_UNEXPLODED][3] = new RagParticle(pRadius[3],pDrag[3]);
         this.pList[STATE_UNEXPLODED][4] = new RagParticle(pRadius[4],pDrag[4]);
         this.pList[STATE_UNEXPLODED][5] = new RagParticle(pRadius[5],pDrag[5]);
         this.pList[STATE_EXPLODED] = new Vector.<RagParticle>(10,true);
         this.pList[STATE_EXPLODED][0] = new RagParticle(pRadius[0],pDrag[0]);
         this.pList[STATE_EXPLODED][1] = new RagParticle(pRadius[1],pDrag[1]);
         this.pList[STATE_EXPLODED][2] = new RagParticle(pRadius[2],pDrag[2]);
         this.pList[STATE_EXPLODED][3] = new RagParticle(pRadius[3],pDrag[3]);
         this.pList[STATE_EXPLODED][4] = new RagParticle(pRadius[4],pDrag[4]);
         this.pList[STATE_EXPLODED][5] = new RagParticle(pRadius[5],pDrag[5]);
         this.pList[STATE_EXPLODED][6] = new RagParticle(pRadius[0],pDrag[0]);
         this.pList[STATE_EXPLODED][7] = new RagParticle(pRadius[0],pDrag[0]);
         this.pList[STATE_EXPLODED][8] = new RagParticle(pRadius[1],pDrag[1]);
         this.pList[STATE_EXPLODED][9] = new RagParticle(pRadius[1],pDrag[1]);
         this.sList = new Vector.<Vector.<RagStick>>(2,true);
         this.sList[STATE_UNEXPLODED] = new Vector.<RagStick>(5,true);
         this.sList[STATE_UNEXPLODED][0] = new RagStick(this.pList[STATE_UNEXPLODED][1],this.pList[STATE_UNEXPLODED][0],sWeight[0],sMinRatio[0],sMaxLen[0]);
         this.sList[STATE_UNEXPLODED][1] = new RagStick(this.pList[STATE_UNEXPLODED][0],this.pList[STATE_UNEXPLODED][2],sWeight[1],sMinRatio[1],sMaxLen[1]);
         this.sList[STATE_UNEXPLODED][2] = new RagStick(this.pList[STATE_UNEXPLODED][0],this.pList[STATE_UNEXPLODED][3],sWeight[2],sMinRatio[2],sMaxLen[2]);
         this.sList[STATE_UNEXPLODED][3] = new RagStick(this.pList[STATE_UNEXPLODED][1],this.pList[STATE_UNEXPLODED][4],sWeight[3],sMinRatio[3],sMaxLen[3]);
         this.sList[STATE_UNEXPLODED][4] = new RagStick(this.pList[STATE_UNEXPLODED][1],this.pList[STATE_UNEXPLODED][5],sWeight[4],sMinRatio[4],sMaxLen[4]);
         this.sList[STATE_EXPLODED] = new Vector.<RagStick>(5,true);
         this.sList[STATE_EXPLODED][0] = new RagStick(this.pList[STATE_EXPLODED][1],this.pList[STATE_EXPLODED][0],sWeight[0],sMinRatio[0],sMaxLen[0]);
         this.sList[STATE_EXPLODED][1] = new RagStick(this.pList[STATE_EXPLODED][6],this.pList[STATE_EXPLODED][2],sWeight[1],sMinRatio[1],sMaxLen[1]);
         this.sList[STATE_EXPLODED][2] = new RagStick(this.pList[STATE_EXPLODED][7],this.pList[STATE_EXPLODED][3],sWeight[2],sMinRatio[2],sMaxLen[2]);
         this.sList[STATE_EXPLODED][3] = new RagStick(this.pList[STATE_EXPLODED][8],this.pList[STATE_EXPLODED][4],sWeight[3],sMinRatio[3],sMaxLen[3]);
         this.sList[STATE_EXPLODED][4] = new RagStick(this.pList[STATE_EXPLODED][9],this.pList[STATE_EXPLODED][5],sWeight[4],sMinRatio[4],sMaxLen[4]);
         this.objList = new Vector.<Entity_Base>();
         this.result_logical = new collision_result_logical();
         this.result_physical = new collision_result_physical();
         this.cp = new vec2();
      }
      
      public function ActivateRagdoll(param1:vec2, param2:vec2, param3:vec2, param4:vec2, param5:Vector.<vec2>, param6:Vector.<vec2>) : void
      {
         var _loc7_:Vector.<vec2> = null;
         var _loc8_:Vector.<vec2> = null;
         this.cur_state = STATE_UNEXPLODED;
         this.explosion_accumulator = 0;
         if(param5 != null && param6 != null)
         {
            _loc7_ = param5;
            _loc8_ = param6;
         }
         else
         {
            trace("WARNING! ragdoll wasn\'t passed in a pose.. this should never happen.");
            _loc7_ = debugpose_pos;
            _loc8_ = debugpose_vel;
         }
         this.pList[STATE_UNEXPLODED][0].SetState(param1.x + _loc7_[0].x,param1.y + _loc7_[0].y,param2.x + _loc8_[0].x,param2.y + _loc8_[0].y);
         this.pList[STATE_UNEXPLODED][1].SetState(param1.x + _loc7_[1].x,param1.y + _loc7_[1].y,param2.x + _loc8_[1].x,param2.y + _loc8_[1].y);
         this.pList[STATE_UNEXPLODED][2].SetState(param1.x + _loc7_[2].x,param1.y + _loc7_[2].y,param2.x + _loc8_[2].x,param2.y + _loc8_[2].y);
         this.pList[STATE_UNEXPLODED][3].SetState(param1.x + _loc7_[3].x,param1.y + _loc7_[3].y,param2.x + _loc8_[3].x,param2.y + _loc8_[3].y);
         this.pList[STATE_UNEXPLODED][4].SetState(param1.x + _loc7_[4].x,param1.y + _loc7_[4].y,param2.x + _loc8_[4].x,param2.y + _loc8_[4].y);
         this.pList[STATE_UNEXPLODED][5].SetState(param1.x + _loc7_[5].x,param1.y + _loc7_[5].y,param2.x + _loc8_[5].x,param2.y + _loc8_[5].y);
         this.ShoveRagdoll(param3,param4);
      }
      
      private function ShoveRagdoll(param1:vec2, param2:vec2) : void
      {
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc3_:Number = 12;
         var _loc4_:Number = 0.5;
         var _loc5_:Number = 1.5;
         var _loc6_:int = 0;
         while(_loc6_ < this.pList[STATE_UNEXPLODED].length)
         {
            _loc7_ = this.pList[STATE_UNEXPLODED][_loc6_].pos.x - param1.x;
            _loc8_ = this.pList[STATE_UNEXPLODED][_loc6_].pos.y - param1.y;
            _loc9_ = Math.sqrt(_loc7_ * _loc7_ + _loc8_ * _loc8_);
            _loc10_ = Math.min(1,_loc9_ / _loc3_);
            _loc11_ = _loc4_ + (1 - _loc10_) * _loc5_;
            this.pList[STATE_UNEXPLODED][_loc6_].vel.x += param2.x * _loc11_;
            this.pList[STATE_UNEXPLODED][_loc6_].vel.y += param2.y * _loc11_;
            _loc6_++;
         }
      }
      
      private function ShoveParticle() : void
      {
      }
      
      public function DEBUG_IsExploded() : Boolean
      {
         return this.cur_state == STATE_EXPLODED;
      }
      
      public function ExplodeRagdoll(param1:Simulator) : void
      {
         var _loc2_:int = 0;
         if(this.cur_state != STATE_EXPLODED)
         {
            this.cur_state = STATE_EXPLODED;
            this.InitUnexplodedParticles();
            _loc2_ = 6;
            while(_loc2_ < 10)
            {
               param1.HACKY_GetParticleManager().Spawn_BloodSpurt(this.pList[STATE_EXPLODED][_loc2_].pos.x,this.pList[STATE_EXPLODED][_loc2_].pos.y,Math.random() * 8 - 4,Math.random() * 8 - 4,3);
               _loc2_++;
            }
         }
      }
      
      public function UnexplodeRagdoll() : void
      {
         var _loc1_:int = 0;
         if(this.cur_state != STATE_UNEXPLODED)
         {
            this.cur_state = STATE_UNEXPLODED;
            _loc1_ = 0;
            while(_loc1_ < 6)
            {
               this.pList[STATE_UNEXPLODED][_loc1_].CopyState(this.pList[STATE_EXPLODED][_loc1_]);
               _loc1_++;
            }
         }
      }
      
      private function InitUnexplodedParticles() : void
      {
         this.pList[STATE_EXPLODED][0].CopyState(this.pList[STATE_UNEXPLODED][0]);
         this.pList[STATE_EXPLODED][1].CopyState(this.pList[STATE_UNEXPLODED][1]);
         this.pList[STATE_EXPLODED][2].CopyState(this.pList[STATE_UNEXPLODED][2]);
         this.pList[STATE_EXPLODED][3].CopyState(this.pList[STATE_UNEXPLODED][3]);
         this.pList[STATE_EXPLODED][4].CopyState(this.pList[STATE_UNEXPLODED][4]);
         this.pList[STATE_EXPLODED][5].CopyState(this.pList[STATE_UNEXPLODED][5]);
         this.pList[STATE_EXPLODED][6].CopyState(this.pList[STATE_UNEXPLODED][0]);
         this.pList[STATE_EXPLODED][7].CopyState(this.pList[STATE_UNEXPLODED][0]);
         this.pList[STATE_EXPLODED][8].CopyState(this.pList[STATE_UNEXPLODED][1]);
         this.pList[STATE_EXPLODED][9].CopyState(this.pList[STATE_UNEXPLODED][1]);
         this.pList[STATE_EXPLODED][6].vel.x += 2;
         this.pList[STATE_EXPLODED][7].vel.y += 4;
         this.pList[STATE_EXPLODED][8].vel.y -= 6;
         this.pList[STATE_EXPLODED][9].vel.x -= 8;
      }
      
      public function Integrate(param1:Number) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.pList[this.cur_state].length)
         {
            this.pList[this.cur_state][_loc2_].PreIntegrate(param1);
            _loc2_++;
         }
      }
      
      public function PreCollision() : void
      {
      }
      
      public function SolveConstraints() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this.sList[this.cur_state].length)
         {
            this.sList[this.cur_state][_loc1_].Solve();
            _loc1_++;
         }
      }
      
      public function PostCollision(param1:Simulator) : void
      {
         var _loc5_:RagParticle = null;
         var _loc6_:int = 0;
         var _loc7_:Entity_Base = null;
         var _loc2_:int = 0;
         while(_loc2_ < this.pList[this.cur_state].length)
         {
            this.pList[this.cur_state][_loc2_].PostIntegrate();
            _loc2_++;
         }
         var _loc3_:Number = 0.1;
         this.result_logical.Clear();
         var _loc4_:int = 0;
         while(_loc4_ < this.pList[this.cur_state].length)
         {
            _loc5_ = this.pList[this.cur_state][_loc4_];
            param1.objGrid.GatherCellContentsInNeighbourhood(_loc5_.pos,this.objList);
            _loc6_ = 0;
            while(_loc6_ < this.objList.length)
            {
               _loc7_ = this.objList[_loc6_];
               if(_loc7_.CollideVsCircle_Logical(param1,null,this.result_logical,_loc5_.pos,_loc5_.vel,_loc5_.pos,_loc5_.r,_loc3_))
               {
                  _loc5_.vel.x += this.result_logical.vec_x;
                  _loc5_.vel.y += this.result_logical.vec_y;
                  if(_loc7_ is Entity_Mine)
                  {
                     if(this.cur_state == STATE_UNEXPLODED)
                     {
                        this.explosion_accumulator += mathutils.Random() * 0.6;
                        if(Math.random() < this.explosion_accumulator)
                        {
                           this.ExplodeRagdoll(param1);
                        }
                     }
                  }
                  else if(_loc7_ is Entity_Drone_Zap || _loc7_ is Entity_FloorGuard || _loc7_ is Entity_Thwomp)
                  {
                     if(Math.random() < 0.5)
                     {
                        param1.HACKY_GetSoundManager().PlaySound_Ragdoll("zap1");
                     }
                     else
                     {
                        param1.HACKY_GetSoundManager().PlaySound_Ragdoll("zap2");
                     }
                  }
               }
               _loc6_++;
            }
            _loc4_++;
         }
      }
      
      public function CollideVsObjects(param1:Simulator) : void
      {
         var _loc3_:RagParticle = null;
         var _loc4_:int = 0;
         var _loc5_:Entity_Base = null;
         this.result_physical.Clear();
         var _loc2_:int = 0;
         while(_loc2_ < this.pList[this.cur_state].length)
         {
            _loc3_ = this.pList[this.cur_state][_loc2_];
            param1.objGrid.GatherCellContentsInNeighbourhood(_loc3_.solver_pos,this.objList);
            _loc4_ = 0;
            while(_loc4_ < this.objList.length)
            {
               _loc5_ = this.objList[_loc4_];
               if(_loc5_.CollideVsCircle_Physical(this.result_physical,_loc3_.solver_pos,_loc3_.vel,_loc3_.pos,_loc3_.r))
               {
                  this.RespondToCollision(param1,_loc3_,this.result_physical.nx,this.result_physical.ny,this.result_physical.pen);
               }
               _loc4_++;
            }
            _loc2_++;
         }
      }
      
      public function CollideVsTiles(param1:Simulator) : void
      {
         var _loc3_:RagParticle = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc2_:int = 0;
         while(_loc2_ < this.pList[this.cur_state].length)
         {
            _loc3_ = this.pList[this.cur_state][_loc2_];
            _loc4_ = 32;
            _loc5_ = 0;
            this.cp.x = 0;
            this.cp.y = 0;
            while(true)
            {
               _loc6_ = colutils.GetSingleClosestPoint_Signed(param1.segGrid,_loc3_.solver_pos,_loc3_.r * 4,this.cp);
               if(_loc6_ == 0)
               {
                  break;
               }
               _loc7_ = _loc3_.solver_pos.x - this.cp.x;
               _loc8_ = _loc3_.solver_pos.y - this.cp.y;
               _loc9_ = Math.sqrt(_loc7_ * _loc7_ + _loc8_ * _loc8_);
               _loc10_ = _loc3_.r - _loc6_ * _loc9_;
               if(_loc10_ < 1e-7)
               {
                  break;
               }
               if(_loc9_ == 0)
               {
                  return;
               }
               _loc7_ /= _loc9_;
               _loc8_ /= _loc9_;
               this.RespondToCollision(param1,_loc3_,_loc7_,_loc8_,_loc6_ * _loc10_);
               _loc5_++;
               if(_loc5_ >= _loc4_)
               {
                  trace("WARNING! ragdoll collision loop hit max iterations: " + _loc10_ + " [" + _loc2_ + "]");
                  break;
               }
            }
            _loc2_++;
         }
      }
      
      private function RespondToCollision(param1:Simulator, param2:RagParticle, param3:Number, param4:Number, param5:Number) : void
      {
         var _loc13_:Number = NaN;
         param2.solver_pos.x += param5 * param3;
         param2.solver_pos.y += param5 * param4;
         var _loc6_:Number = 0;
         var _loc7_:Number = 0.05;
         var _loc8_:Number = 0;
         var _loc9_:Number = param2.solver_pos.x - param2.pos.x;
         var _loc10_:Number = param2.solver_pos.y - param2.pos.y;
         var _loc11_:Number = _loc9_ * param3 + _loc10_ * param4;
         var _loc12_:Number = _loc9_ * -param4 + _loc10_ * param3;
         if(_loc11_ < 0)
         {
            _loc6_ = 2;
            _loc7_ = 0.15;
            _loc8_ = 1;
            if(_loc11_ < -3)
            {
               param1.HACKY_GetParticleManager().Spawn_RagBloodSpurt(param2.solver_pos.x,param2.solver_pos.y,-_loc11_ * param3,-_loc11_ * param4);
               _loc13_ = Math.random();
               if(_loc13_ < 0.33)
               {
                  param1.HACKY_GetSoundManager().PlaySound_Ragdoll("hard1");
               }
               else if(_loc13_ < 0.66)
               {
                  param1.HACKY_GetSoundManager().PlaySound_Ragdoll("hard2");
               }
               else
               {
                  param1.HACKY_GetSoundManager().PlaySound_Ragdoll("hard3");
               }
            }
            else
            {
               if(0.7 < _loc12_ * _loc12_)
               {
                  param1.HACKY_GetParticleManager().Spawn_RagDust(param2.solver_pos,param2.r,_loc12_ * -param4,_loc12_ * param3,_loc12_ * _loc12_);
               }
               if(_loc11_ < -2)
               {
                  if(Math.random() < 0.5)
                  {
                     param1.HACKY_GetSoundManager().PlaySound_Ragdoll("med1");
                  }
                  else
                  {
                     param1.HACKY_GetSoundManager().PlaySound_Ragdoll("med2");
                  }
               }
               else if(_loc11_ < -1.2)
               {
                  if(Math.random() < 0.5)
                  {
                     param1.HACKY_GetSoundManager().PlaySound_Ragdoll("soft1");
                  }
                  else
                  {
                     param1.HACKY_GetSoundManager().PlaySound_Ragdoll("soft2");
                  }
               }
            }
         }
         param2.pos.x += _loc8_ * param5 * param3 + _loc6_ * _loc11_ * param3 + _loc7_ * _loc12_ * -param4;
         param2.pos.y += _loc8_ * param5 * param4 + _loc6_ * _loc11_ * param4 + _loc7_ * _loc12_ * param3;
      }
      
      public function GFX_UpdateState(param1:EntityGraphics_Ninja) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc2_:int = 0;
         while(_loc2_ < this.sList[this.cur_state].length)
         {
            _loc3_ = this.sList[this.cur_state][_loc2_].p1.pos.x - this.sList[this.cur_state][_loc2_].p0.pos.x;
            _loc4_ = this.sList[this.cur_state][_loc2_].p1.pos.y - this.sList[this.cur_state][_loc2_].p0.pos.y;
            _loc5_ = Math.sqrt(_loc3_ * _loc3_ + _loc4_ * _loc4_);
            param1.ragdoll_posList[_loc2_].Copy(this.sList[this.cur_state][_loc2_].p0.pos);
            param1.ragdoll_ornList[_loc2_] = Math.atan2(_loc4_,_loc3_);
            param1.ragdoll_lenList[_loc2_] = Math.max(0,Math.min(1,_loc5_ / this.sList[this.cur_state][_loc2_].maxlen));
            _loc2_++;
         }
      }
      
      public function TESTING_SetPosVel(param1:vec2, param2:vec2) : void
      {
         this.pList[this.cur_state][0].pos.Copy(param1);
         this.pList[this.cur_state][0].vel.Copy(param2);
      }
      
      public function Draw(param1:SimpleRenderer) : void
      {
         var _loc4_:vec2 = null;
         var _loc5_:vec2 = null;
         param1.SetStyle(0,0,100);
         var _loc2_:int = 0;
         while(_loc2_ < this.pList[this.cur_state].length)
         {
            param1.DrawCircle(this.pList[this.cur_state][_loc2_].pos.x,this.pList[this.cur_state][_loc2_].pos.y,this.pList[this.cur_state][_loc2_].r);
            _loc2_++;
         }
         var _loc3_:int = 0;
         while(_loc3_ < this.sList[this.cur_state].length)
         {
            _loc4_ = this.sList[this.cur_state][_loc3_].p0.pos;
            _loc5_ = this.sList[this.cur_state][_loc3_].p1.pos;
            param1.DrawLine(_loc4_.x,_loc4_.y,_loc5_.x,_loc5_.y);
            _loc3_++;
         }
      }
   }
}

import math.vec2;

class RagParticle
{
   
   public var pos:vec2;
   
   public var vel:vec2;
   
   public var solver_pos:vec2;
   
   public var r:Number;
   
   public var d:Number;
   
   public function RagParticle(param1:Number, param2:Number)
   {
      super();
      this.pos = new vec2();
      this.vel = new vec2();
      this.solver_pos = new vec2();
      this.r = param1;
      this.d = param2;
   }
   
   public function PreIntegrate(param1:Number) : void
   {
      this.vel.x *= this.d;
      this.vel.y *= this.d;
      this.vel.y += param1;
      this.solver_pos.x = this.pos.x + this.vel.x;
      this.solver_pos.y = this.pos.y + this.vel.y;
   }
   
   public function PostIntegrate() : void
   {
      this.vel.x = this.solver_pos.x - this.pos.x;
      this.vel.y = this.solver_pos.y - this.pos.y;
      this.pos.x = this.solver_pos.x;
      this.pos.y = this.solver_pos.y;
   }
   
   public function SetState(param1:Number, param2:Number, param3:Number, param4:Number) : void
   {
      this.pos.x = param1;
      this.pos.y = param2;
      this.vel.x = param3;
      this.vel.y = param4;
   }
   
   public function CopyState(param1:RagParticle) : void
   {
      this.pos.Copy(param1.pos);
      this.vel.Copy(param1.vel);
   }
}

class RagStick
{
   
   public var p0:RagParticle;
   
   public var p1:RagParticle;
   
   public var w0:Number;
   
   public var w1:Number;
   
   public var minlen:Number;
   
   public var maxlen:Number;
   
   public function RagStick(param1:RagParticle, param2:RagParticle, param3:Number, param4:Number, param5:Number)
   {
      super();
      this.p0 = param1;
      this.p1 = param2;
      this.w0 = param3;
      this.w1 = 1 - this.w0;
      this.minlen = param5 * param4;
      this.maxlen = param5;
   }
   
   public function Solve() : void
   {
      var _loc1_:Number = this.p1.solver_pos.x - this.p0.solver_pos.x;
      var _loc2_:Number = this.p1.solver_pos.y - this.p0.solver_pos.y;
      var _loc3_:Number = Math.sqrt(_loc1_ * _loc1_ + _loc2_ * _loc2_);
      if(this.minlen <= _loc3_ && _loc3_ <= this.maxlen)
      {
         return;
      }
      var _loc4_:Number = Math.max(this.minlen,Math.min(this.maxlen,_loc3_));
      var _loc5_:Number = _loc3_ - _loc4_;
      var _loc6_:Number = 1;
      var _loc7_:Number = 0;
      if(_loc3_ != 0)
      {
         _loc6_ = _loc1_ / _loc3_;
         _loc7_ = _loc2_ / _loc3_;
      }
      this.p0.solver_pos.x -= this.w0 * -_loc5_ * _loc6_;
      this.p0.solver_pos.y -= this.w0 * -_loc5_ * _loc7_;
      this.p1.solver_pos.x += this.w1 * -_loc5_ * _loc6_;
      this.p1.solver_pos.y += this.w1 * -_loc5_ * _loc7_;
   }
}
