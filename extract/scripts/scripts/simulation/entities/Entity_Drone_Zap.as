package simulation.entities
{
   import audiovisual.entitygraphics.EntityGraphics;
   import audiovisual.entitygraphics.EntityGraphics_Drone_Zap;
   import math.vec2;
   import simpleFramework.SimpleRenderer;
   import simulation.Simulator;
   import simulation.collision.Grid_Entity;
   import simulation.collision.colutils;
   import simulation.ninja.Ninja;
   import simulation.sim_globals;
   
   public class Entity_Drone_Zap extends Entity_Drone_Base
   {
      
      public function Entity_Drone_Zap(param1:Grid_Entity, param2:Number, param3:Number, param4:uint, param5:uint)
      {
         var _loc6_:Number = 12 * (1 / 14) * 2 * (40 / sim_globals.sim_rate);
         super(param1,param2,param3,_loc6_,param4,param5);
      }
      
      final override public function CollideVsCircle_Logical(param1:Simulator, param2:Ninja, param3:collision_result_logical, param4:vec2, param5:vec2, param6:vec2, param7:Number, param8:Number) : Boolean
      {
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         if(colutils.Overlap_Circle_Vs_Circle(pos,r,param4,param7))
         {
            _loc9_ = param4.x - pos.x;
            _loc10_ = param4.y - pos.y;
            _loc11_ = Math.sqrt(_loc9_ * _loc9_ + _loc10_ * _loc10_);
            _loc9_ /= _loc11_;
            _loc10_ /= _loc11_;
            param1.HACKY_GetParticleManager().Spawn_Zap(pos.x + _loc9_ * r,pos.y + _loc10_ * r,Math.atan2(_loc10_,_loc9_) / Math.PI * 180);
            if(param2 == null)
            {
               param3.vec_x = _loc9_ * 12;
               param3.vec_y = _loc10_ * 12 - 4;
               return true;
            }
            param1.Event_PlayerWasKilled(param2,sim_globals.ENEMYTYPE_ZAP,param4.x - _loc9_ * param7,param4.y - _loc10_ * param7,_loc9_ * 12,_loc10_ * 12 - 4);
         }
         return false;
      }
      
      override public function GenerateGraphicComponent() : EntityGraphics
      {
         return new EntityGraphics_Drone_Zap(this);
      }
      
      public function GFX_UpdateState(param1:EntityGraphics) : void
      {
         var _loc2_:EntityGraphics_Drone_Zap = param1 as EntityGraphics_Drone_Zap;
         _loc2_.pos.x = pos.x;
         _loc2_.pos.y = pos.y;
         _loc2_.orn = gfxorn;
      }
      
      override public function Debug_Draw(param1:SimpleRenderer) : void
      {
         super.Debug_Draw(param1);
         param1.SetStyle(4,8947967,50);
         param1.DrawCircle(pos.x,pos.y,r / 2);
      }
   }
}

