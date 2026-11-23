package simulation.entities
{
   import math.vec2;
   import simpleFramework.SimpleRenderer;
   import simulation.Simulator;
   import simulation.collision.Grid_Entity;
   
   public class Entity_Drone_Shooter_Base extends Entity_Drone_Base
   {
      
      private static var zero_vec:vec2 = new vec2();
      
      protected static const FIRING_STATE_IDLE:int = 0;
      
      protected static const FIRING_STATE_PREFIRING:int = 1;
      
      protected static const FIRING_STATE_FIRING:int = 2;
      
      protected static const FIRING_STATE_POSTFIRING:int = 3;
      
      private var prefire_delay:int;
      
      private var postfire_delay:int;
      
      private var firing_timer:int;
      
      private var CUR_FIRING_STATE:int;
      
      private var targetIndex:int;
      
      public function Entity_Drone_Shooter_Base(param1:Grid_Entity, param2:Number, param3:Number, param4:Number, param5:uint, param6:uint, param7:int, param8:int)
      {
         super(param1,param2,param3,param4,param5,param6);
         this.CUR_FIRING_STATE = FIRING_STATE_IDLE;
         this.firing_timer = 0;
         this.prefire_delay = param7;
         this.postfire_delay = param8;
         this.targetIndex = -1;
      }
      
      final override public function Move(param1:Simulator) : void
      {
         if(this.CUR_FIRING_STATE == FIRING_STATE_IDLE)
         {
            super.Move(param1);
         }
      }
      
      final protected function GetFiringState() : int
      {
         return this.CUR_FIRING_STATE;
      }
      
      final override public function Think(param1:Simulator) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(this.CUR_FIRING_STATE == FIRING_STATE_IDLE)
         {
            _loc2_ = entity_helpers.TryToAquireTarget(pos,param1.playerList,param1.segGrid);
            if(0 <= _loc2_)
            {
               this.Internal_StartPrefiring(param1,_loc2_,param1.playerList[_loc2_].GetPos());
               return;
            }
         }
         else
         {
            if(this.targetIndex < 0)
            {
               trace("WARNING! Entity_Drone_Shooter_Base.Think() isn\'t idle, but has an invalid target index!: " + this.targetIndex);
               return;
            }
            if(this.CUR_FIRING_STATE == FIRING_STATE_PREFIRING)
            {
               if(param1.playerList[this.targetIndex].IsDead())
               {
                  this.Internal_StartPostfiring(param1);
               }
               else
               {
                  this.Update_Prefiring(param1,param1.playerList[this.targetIndex].GetPos());
                  ++this.firing_timer;
                  if(this.prefire_delay <= this.firing_timer)
                  {
                     this.Internal_StartFiring(param1,param1.playerList[this.targetIndex].GetPos(),param1.playerList[this.targetIndex].GetVel());
                  }
               }
            }
            else if(this.CUR_FIRING_STATE == FIRING_STATE_FIRING)
            {
               if(this.Update_Firing(param1))
               {
                  this.Internal_StartPostfiring(param1);
               }
            }
            else if(this.CUR_FIRING_STATE == FIRING_STATE_POSTFIRING)
            {
               ++this.firing_timer;
               if(this.postfire_delay <= this.firing_timer)
               {
                  _loc3_ = 0;
                  while(_loc3_ < param1.playerList.length)
                  {
                     if(!param1.playerList[_loc3_].IsDead())
                     {
                        if(param1.segGrid.RaycastVsPlayer(pos,param1.playerList[_loc3_].GetPos(),param1.playerList[_loc3_].GetRadius(),zero_vec,zero_vec))
                        {
                           this.Internal_StartPrefiring(param1,_loc3_,param1.playerList[_loc3_].GetPos());
                           return;
                        }
                     }
                     _loc3_++;
                  }
                  this.Internal_StartIdling();
               }
            }
         }
      }
      
      final private function Internal_StartPrefiring(param1:Simulator, param2:int, param3:vec2) : void
      {
         this.firing_timer = 0;
         this.CUR_FIRING_STATE = FIRING_STATE_PREFIRING;
         this.targetIndex = param2;
         this.Start_Prefiring(param1,param3);
      }
      
      final private function Internal_StartFiring(param1:Simulator, param2:vec2, param3:vec2) : void
      {
         this.CUR_FIRING_STATE = FIRING_STATE_FIRING;
         this.Start_Firing(param1,param2,param3);
      }
      
      final private function Internal_StartPostfiring(param1:Simulator) : void
      {
         this.firing_timer = 0;
         this.CUR_FIRING_STATE = FIRING_STATE_POSTFIRING;
         this.Start_Postfiring(param1);
      }
      
      final private function Internal_StartIdling() : void
      {
         this.CUR_FIRING_STATE = FIRING_STATE_IDLE;
         this.targetIndex = -1;
      }
      
      protected function Start_Prefiring(param1:Simulator, param2:vec2) : void
      {
      }
      
      protected function Update_Prefiring(param1:Simulator, param2:vec2) : void
      {
      }
      
      protected function Start_Firing(param1:Simulator, param2:vec2, param3:vec2) : void
      {
      }
      
      protected function Update_Firing(param1:Simulator) : Boolean
      {
         return true;
      }
      
      protected function Start_Postfiring(param1:Simulator) : void
      {
      }
      
      override public function Debug_Draw(param1:SimpleRenderer) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         super.Debug_Draw(param1);
         param1.SetStyle(0,0,100);
         if(this.CUR_FIRING_STATE == FIRING_STATE_PREFIRING)
         {
            _loc2_ = Number(this.firing_timer) / Number(this.prefire_delay);
            param1.DrawSquare(pos.x,pos.y,r * _loc2_);
         }
         else if(this.CUR_FIRING_STATE == FIRING_STATE_POSTFIRING)
         {
            _loc3_ = 1 - Number(this.firing_timer) / Number(this.postfire_delay);
            param1.DrawSquare(pos.x,pos.y,r * _loc3_);
         }
      }
   }
}

