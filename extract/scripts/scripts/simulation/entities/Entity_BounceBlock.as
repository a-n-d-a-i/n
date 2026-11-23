package simulation.entities
{
   import audiovisual.entitygraphics.EntityGraphics;
   import audiovisual.entitygraphics.EntityGraphics_BounceBlock;
   import math.vec2;
   import simpleFramework.SimpleRenderer;
   import simulation.Simulator;
   import simulation.collision.Grid_Entity;
   import simulation.collision.colutils;
   import simulation.ninja.Ninja;
   import simulation.sim_globals;
   
   public class Entity_BounceBlock extends Entity_Base
   {
      
      private var pos:vec2;
      
      private var vel:vec2;
      
      private var anchor:vec2;
      
      private var r:Number;
      
      private var stiff:Number;
      
      private var damp:Number;
      
      private var mass:Number;
      
      private var isSleeping:Boolean;
      
      private var n:vec2;
      
      public function Entity_BounceBlock(param1:Grid_Entity, param2:Number, param3:Number)
      {
         super();
         this.pos = new vec2(param2,param3);
         this.vel = new vec2(0,0);
         this.anchor = new vec2(param2,param3);
         this.r = 0.8 * 12;
         this.stiff = 0.05 * (40 / sim_globals.sim_rate) * (40 / sim_globals.sim_rate);
         this.damp = 0.99;
         if(sim_globals.sim_rate == 60)
         {
            this.damp = 0.98;
         }
         this.mass = 0.2;
         this.isSleeping = true;
         param1.ENTITY_Add(this.pos,this);
         this.n = new vec2();
      }
      
      override public function CollideVsCircle_Physical(param1:collision_result_physical, param2:vec2, param3:vec2, param4:vec2, param5:Number) : Boolean
      {
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         this.n.x = 0;
         this.n.y = 0;
         _loc6_ = colutils.Penetration_Square_vs_Point(this.pos,this.r + param5,param2,this.n);
         if(_loc6_ != 0)
         {
            _loc7_ = (1 - this.mass) * _loc6_;
            this.pos.x -= _loc7_ * this.n.x;
            this.vel.x -= _loc7_ * this.n.x;
            this.pos.y -= _loc7_ * this.n.y;
            this.vel.y -= _loc7_ * this.n.y;
            param1.isHardCollision = false;
            param1.nx = this.n.x;
            param1.ny = this.n.y;
            param1.pen = this.mass * _loc6_;
            return true;
         }
         return false;
      }
      
      override public function CollideVsCircle_Logical(param1:Simulator, param2:Ninja, param3:collision_result_logical, param4:vec2, param5:vec2, param6:vec2, param7:Number, param8:Number) : Boolean
      {
         var _loc9_:Number = NaN;
         if(param2 != null)
         {
            this.n.x = 0;
            this.n.y = 0;
            _loc9_ = colutils.Penetration_Square_vs_Point(this.pos,param8 + this.r + param7,param4,this.n);
            if(_loc9_ != 0)
            {
               param3.vec_x = this.n.x;
               param3.vec_y = this.n.y;
               return true;
            }
         }
         return false;
      }
      
      override public function Think(param1:Simulator) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         if(!this.isSleeping)
         {
            _loc2_ = this.anchor.x - this.pos.x;
            _loc3_ = this.anchor.y - this.pos.y;
            _loc4_ = _loc2_ * _loc2_ + _loc3_ * _loc3_;
            if(this.vel.LenSq() < 0.05 && _loc4_ < 0.05)
            {
               this.pos.Copy(this.anchor);
               this.vel.x = 0;
               this.vel.y = 0;
               this.isSleeping = true;
            }
         }
      }
      
      override public function Move(param1:Simulator) : void
      {
         this.vel.Scale(this.damp);
         this.pos.x += this.vel.x;
         this.pos.y += this.vel.y;
         var _loc2_:Number = this.anchor.x - this.pos.x;
         var _loc3_:Number = this.anchor.y - this.pos.y;
         _loc2_ *= this.stiff;
         _loc3_ *= this.stiff;
         this.pos.x += _loc2_;
         this.pos.y += _loc3_;
         this.vel.x += _loc2_;
         this.vel.y += _loc3_;
         param1.objGrid.ENTITY_Move(this.pos,this);
      }
      
      override public function GenerateGraphicComponent() : EntityGraphics
      {
         return new EntityGraphics_BounceBlock(this);
      }
      
      public function GFX_UpdateState(param1:EntityGraphics_BounceBlock) : void
      {
         param1.pos.x = this.pos.x;
         param1.pos.y = this.pos.y;
      }
      
      override public function Debug_Draw(param1:SimpleRenderer) : void
      {
         if(this.isSleeping)
         {
            param1.SetStyle(0,0,30);
         }
         else
         {
            param1.SetStyle(0,0,100);
         }
         param1.DrawSquare(this.pos.x,this.pos.y,this.r);
      }
   }
}

