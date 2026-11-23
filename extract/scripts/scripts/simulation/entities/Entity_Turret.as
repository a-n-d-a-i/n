package simulation.entities
{
   import audiovisual.entitygraphics.EntityGraphics;
   import audiovisual.entitygraphics.EntityGraphics_Turret;
   import math.vec2;
   import simpleFramework.SimpleRenderer;
   import simulation.Simulator;
   import simulation.collision.Grid_Entity;
   import simulation.collision.colutils;
   import simulation.ninja.Ninja;
   import simulation.sim_globals;
   
   public class Entity_Turret extends Entity_Base
   {
      
      private static const STATE_IDLE:int = 0;
      
      private static const STATE_TARGETTING:int = 1;
      
      private static const STATE_PREFIRE:int = 2;
      
      private static const STATE_POSTFIRE:int = 3;
      
      private var threshold2:Vector.<Number>;
      
      private var aimspeed:Vector.<Number>;
      
      private var timerstep:Vector.<Number>;
      
      private var prediction_scale:Number;
      
      private var pos:vec2;
      
      private var aim_pos:vec2;
      
      private var aim_region:int;
      
      private var shot_timer:Number;
      
      private var CUR_STATE:int;
      
      private var targetIndex:int;
      
      private var gfx_triggerEvent:Boolean;
      
      private var HACKY_drawtimer:int;
      
      private var HACKY_hit_pos:vec2;
      
      private var HACKY_hit_n:vec2;
      
      private var timer_firetime:Number;
      
      private var prefire_delay:Number;
      
      private var postfire_delay:Number;
      
      private var TEMP_hit_pos:vec2;
      
      private var TEMP_hit_n:vec2;
      
      public function Entity_Turret(param1:Grid_Entity, param2:Number, param3:Number)
      {
         super();
         this.timer_firetime = 60 * (sim_globals.sim_rate / 40);
         this.prefire_delay = 10 * (sim_globals.sim_rate / 40);
         this.postfire_delay = 10 * (sim_globals.sim_rate / 40);
         this.threshold2 = new Vector.<Number>(3,true);
         this.threshold2[0] = 9216;
         this.threshold2[1] = 1764;
         this.threshold2[2] = 576;
         this.aimspeed = new Vector.<Number>(4,true);
         this.aimspeed[0] = 0.03 * (40 / sim_globals.sim_rate);
         this.aimspeed[1] = 0.035 * (40 / sim_globals.sim_rate);
         this.aimspeed[2] = 0.05 * (40 / sim_globals.sim_rate);
         this.aimspeed[3] = 0.05 * (40 / sim_globals.sim_rate);
         this.timerstep = new Vector.<Number>(4,true);
         this.timerstep[0] = 0;
         this.timerstep[1] = 0.5;
         this.timerstep[2] = 1.5;
         this.timerstep[3] = 3.5;
         this.prediction_scale = sim_globals.sim_rate / 40;
         this.pos = new vec2(param2,param3);
         this.aim_pos = new vec2(param2,param3);
         this.aim_region = 0;
         this.shot_timer = 0;
         this.CUR_STATE = STATE_IDLE;
         this.targetIndex = -1;
         this.gfx_triggerEvent = false;
         this.HACKY_drawtimer = 0;
         this.HACKY_hit_pos = new vec2();
         this.HACKY_hit_n = new vec2();
         this.TEMP_hit_pos = new vec2();
         this.TEMP_hit_n = new vec2();
      }
      
      override public function Think(param1:Simulator) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:int = 0;
         var _loc8_:vec2 = null;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         this.TEMP_hit_pos.x = 0;
         this.TEMP_hit_pos.y = 0;
         this.TEMP_hit_n.x = 0;
         this.TEMP_hit_n.y = 0;
         if(this.CUR_STATE == STATE_IDLE)
         {
            _loc2_ = entity_helpers.TryToAquireTarget(this.pos,param1.playerList,param1.segGrid);
            if(0 <= _loc2_)
            {
               this.Event_StartTargetting(_loc2_);
            }
         }
         else
         {
            if(this.targetIndex < 0)
            {
               trace("WARNING! Turret.Think() isn\'t idle, but has an invalid target index!: " + this.targetIndex);
               return;
            }
            if(this.CUR_STATE == STATE_TARGETTING)
            {
               if(!this.IsCurrentTargetVisible(param1,this.TEMP_hit_pos,this.TEMP_hit_n))
               {
                  this.Event_StartIdling();
               }
               else
               {
                  this.UpdateAim(param1.playerList[this.targetIndex].GetPos(),param1.playerList[this.targetIndex].GetVel());
                  if(this.timer_firetime < this.shot_timer)
                  {
                     this.Event_StartFiring();
                  }
               }
            }
            else if(this.CUR_STATE == STATE_PREFIRE)
            {
               ++this.shot_timer;
               if(this.prefire_delay <= this.shot_timer)
               {
                  if(!param1.playerList[this.targetIndex].IsDead())
                  {
                     _loc3_ = this.aim_pos.x - this.pos.x;
                     _loc4_ = this.aim_pos.y - this.pos.y;
                     _loc5_ = Math.sqrt(_loc3_ * _loc3_ + _loc4_ * _loc4_);
                     _loc3_ /= _loc5_;
                     _loc4_ /= _loc5_;
                     _loc6_ = param1.segGrid.GetRaycastDistance(this.pos.x,this.pos.y,_loc3_,_loc4_,this.HACKY_hit_pos,this.HACKY_hit_n);
                     _loc7_ = 0;
                     while(_loc7_ < param1.playerList.length)
                     {
                        if(!param1.playerList[_loc7_].IsDead())
                        {
                           _loc8_ = param1.playerList[_loc7_].GetPos();
                           _loc9_ = param1.playerList[_loc7_].GetRadius();
                           if(colutils.Overlap_Circle_Vs_Segment(_loc8_,_loc9_,this.pos,this.HACKY_hit_pos,_loc6_))
                           {
                              _loc10_ = _loc8_.x - this.pos.x;
                              _loc11_ = _loc8_.y - this.pos.y;
                              _loc12_ = _loc3_ * _loc10_ + _loc4_ * _loc11_;
                              this.HACKY_hit_pos.x = this.pos.x + _loc12_ * _loc3_;
                              this.HACKY_hit_pos.y = this.pos.y + _loc12_ * _loc4_;
                              this.HACKY_hit_n.x = 0;
                              this.HACKY_hit_n.y = 0;
                              param1.Event_PlayerWasKilled(param1.playerList[_loc7_],sim_globals.ENEMYTYPE_TURRET,this.HACKY_hit_pos.x,this.HACKY_hit_pos.y,_loc3_ * 8,_loc4_ * 8);
                           }
                           this.HACKY_drawtimer = 10;
                        }
                        _loc7_++;
                     }
                     param1.HACKY_GetParticleManager().Spawn_TurretBullet(this.pos,this.HACKY_hit_pos);
                     this.gfx_triggerEvent = true;
                  }
                  this.Event_StopFiring();
               }
            }
            else if(this.CUR_STATE == STATE_POSTFIRE)
            {
               ++this.shot_timer;
               if(this.postfire_delay <= this.shot_timer)
               {
                  if(this.IsCurrentTargetVisible(param1,this.TEMP_hit_pos,this.TEMP_hit_n))
                  {
                     this.Event_ResumeTargetting();
                  }
                  else
                  {
                     this.Event_StartIdling();
                  }
               }
            }
         }
      }
      
      private function Event_StartIdling() : void
      {
         this.CUR_STATE = STATE_IDLE;
         this.targetIndex = -1;
      }
      
      private function Event_StartTargetting(param1:int) : void
      {
         this.aim_pos.Copy(this.pos);
         this.shot_timer = 0;
         this.CUR_STATE = STATE_TARGETTING;
         this.targetIndex = param1;
      }
      
      private function Event_ResumeTargetting() : void
      {
         this.shot_timer = 0;
         this.CUR_STATE = STATE_TARGETTING;
      }
      
      private function Event_StartFiring() : void
      {
         this.shot_timer = 0;
         this.CUR_STATE = STATE_PREFIRE;
      }
      
      private function Event_StopFiring() : void
      {
         this.shot_timer = 0;
         this.CUR_STATE = STATE_POSTFIRE;
      }
      
      private function IsCurrentTargetVisible(param1:Simulator, param2:vec2, param3:vec2) : Boolean
      {
         var _loc4_:Ninja = param1.playerList[this.targetIndex];
         var _loc5_:Boolean = false;
         if(!_loc4_.IsDead())
         {
            _loc5_ = param1.segGrid.RaycastVsPlayer(this.pos,_loc4_.GetPos(),_loc4_.GetRadius(),param2,param3);
         }
         return _loc5_;
      }
      
      private function UpdateAim(param1:vec2, param2:vec2) : void
      {
         var _loc3_:Number = param2.x * this.prediction_scale;
         var _loc4_:Number = param2.y * this.prediction_scale;
         var _loc5_:Number = param1.x + _loc3_;
         var _loc6_:Number = param1.y + _loc4_;
         var _loc7_:Number = _loc5_ - this.aim_pos.x;
         var _loc8_:Number = _loc6_ - this.aim_pos.y;
         var _loc9_:Number = _loc7_ * _loc7_ + _loc8_ * _loc8_;
         this.aim_region = 0;
         var _loc10_:int = 0;
         while(_loc10_ < this.threshold2.length)
         {
            if(_loc9_ > this.threshold2[_loc10_])
            {
               break;
            }
            ++this.aim_region;
            _loc10_++;
         }
         this.shot_timer += this.timerstep[this.aim_region];
         var _loc11_:Number = this.aimspeed[this.aim_region];
         this.aim_pos.x += _loc11_ * _loc7_;
         this.aim_pos.y += _loc11_ * _loc8_;
      }
      
      override public function GenerateGraphicComponent() : EntityGraphics
      {
         return new EntityGraphics_Turret(this,this.pos.x,this.pos.y);
      }
      
      public function GFX_UpdateState(param1:EntityGraphics_Turret) : void
      {
         param1.pos_crosshair.x = this.aim_pos.x;
         param1.pos_crosshair.y = this.aim_pos.y;
         if(this.gfx_triggerEvent)
         {
            param1.anim_base = EntityGraphics_Turret.ANIM_FIRING;
            this.gfx_triggerEvent = false;
         }
         else if(this.CUR_STATE == STATE_IDLE)
         {
            param1.anim_base = EntityGraphics_Turret.ANIM_IDLE;
            param1.anim_crosshair = EntityGraphics_Turret.CROSSHAIR_OFF;
         }
         else if(this.CUR_STATE == STATE_PREFIRE)
         {
            param1.anim_base = EntityGraphics_Turret.ANIM_PREFIRE;
            param1.anim_crosshair = EntityGraphics_Turret.CROSSHAIR_PREFIRE;
         }
         else if(this.CUR_STATE == STATE_POSTFIRE)
         {
            param1.anim_base = EntityGraphics_Turret.ANIM_POSTFIRE;
            param1.anim_crosshair = EntityGraphics_Turret.CROSSHAIR_POSTFIRE;
         }
         else if(this.CUR_STATE == STATE_TARGETTING)
         {
            if(this.aim_region == 0)
            {
               param1.anim_crosshair = EntityGraphics_Turret.CROSSHAIR_FAR;
            }
            else if(this.aim_region == 1)
            {
               param1.anim_crosshair = EntityGraphics_Turret.CROSSHAIR_MID;
            }
            else if(this.aim_region == 2)
            {
               param1.anim_crosshair = EntityGraphics_Turret.CROSSHAIR_NEAR;
            }
         }
      }
      
      override public function Debug_Draw(param1:SimpleRenderer) : void
      {
         param1.SetStyle(0,0,100);
         param1.DrawCircle(this.pos.x,this.pos.y,4);
         param1.DrawCross(this.pos.x,this.pos.y,2);
         if(this.CUR_STATE != STATE_IDLE)
         {
            if(this.CUR_STATE == STATE_TARGETTING)
            {
               if(this.aim_region == 0)
               {
                  param1.SetStyle(0,0,50);
                  param1.DrawPlus(this.aim_pos.x,this.aim_pos.y,2);
               }
               else if(this.aim_region == 1)
               {
                  param1.SetStyle(0,0,75);
                  param1.DrawPlus(this.aim_pos.x,this.aim_pos.y,3);
               }
               else if(this.aim_region > 1)
               {
                  param1.SetStyle(0,0,100);
                  param1.DrawPlus(this.aim_pos.x,this.aim_pos.y,4);
               }
            }
            else if(this.CUR_STATE == 2)
            {
               param1.DrawSquare(this.aim_pos.x,this.aim_pos.y,4);
            }
            else if(this.CUR_STATE == 3)
            {
               param1.DrawCircle(this.aim_pos.x,this.aim_pos.y,2);
            }
            param1.SetStyle(0,0,10);
            param1.DrawLine(this.pos.x,this.pos.y,this.aim_pos.x,this.aim_pos.y);
         }
         if(this.HACKY_drawtimer > 0)
         {
            param1.SetStyle(0,0,100 * (Number(this.HACKY_drawtimer) / 10));
            param1.DrawLine(this.pos.x,this.pos.y,this.HACKY_hit_pos.x,this.HACKY_hit_pos.y);
            param1.DrawLine(this.HACKY_hit_pos.x,this.HACKY_hit_pos.y,this.HACKY_hit_pos.x + 4 * this.HACKY_hit_n.x,this.HACKY_hit_pos.y + 4 * this.HACKY_hit_n.y);
            --this.HACKY_drawtimer;
         }
      }
   }
}

