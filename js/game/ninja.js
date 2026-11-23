/* Literal port of simulation/ninja/Ninja.as */
import { vec2 } from "./math.js";
import { colutils } from "./collision.js";
import { Ragdoll } from "./ragdoll.js";
import { sim_globals, collision_result_logical, collision_result_physical,
         Entity_Thwomp } from "./entities.js";
import { EntityGraphics_Ninja } from "./entitygraphics.js";

export class Ninja {
  static PSTATE_STANDING = 0;
  static PSTATE_RUNNING = 1;
  static PSTATE_SKIDDING = 2;
  static PSTATE_JUMPING = 3;
  static PSTATE_FALLING = 4;
  static PSTATE_WALLSLIDING = 5;
  static PSTATE_DEAD = 6;
  static PSTATE_AWAITINGDEATH = 7;
  static PSTATE_CELEBRATING = 8;
  static PSTATE_DISABLED = 9;

  constructor(id, inputsource, x, y, gfxColor = 0) {
    this.pID = id;
    this.inputsource = inputsource;
    this.gfxColor = gfxColor;
    this.pos = new vec2(x, y);
    this.vel = new vec2(0, 0);
    this.oldpos = new vec2(0, 0);
    this.r = 10;
    this.impulse_scale = 40 / sim_globals.sim_rate;
    this.maxspeedAir = this.r * 0.5 * (40 / sim_globals.sim_rate);
    this.maxspeedGround = this.r * 0.5 * (40 / sim_globals.sim_rate);
    this.groundAccel = 0.15 * (40 / sim_globals.sim_rate) * (40 / sim_globals.sim_rate);
    this.airAccel = 0.1 * (40 / sim_globals.sim_rate) * (40 / sim_globals.sim_rate);
    this.normGrav = 0.15 * (40 / sim_globals.sim_rate) * (40 / sim_globals.sim_rate);
    this.jumpGrav = 0.025 * (40 / sim_globals.sim_rate) * (40 / sim_globals.sim_rate);
    this.normDrag = Math.pow(0.99, 40 / sim_globals.sim_rate);
    this.winDrag = Math.pow(0.8, 40 / sim_globals.sim_rate);
    this.wallFriction = Math.pow(0.87, 40 / sim_globals.sim_rate);
    this.skidFriction = Math.pow(0.92, 40 / sim_globals.sim_rate);
    this.standFriction = Math.pow(0.8, 40 / sim_globals.sim_rate);
    this.g = this.normGrav;
    this.d = this.normDrag;
    this.curState = Ninja.PSTATE_DISABLED;
    this.facingDir = 1;
    this.jumpAmt = 1;
    this.jump_y_bias = 2;
    this.max_jump_time = 30 * (sim_globals.sim_rate / 40);
    this.terminal_vel = this.r * 0.9 * (40 / sim_globals.sim_rate);
    this.jumptimer = 0;
    this.wasJdown = false;
    this.oldv = new vec2(0, 0);
    this.WAS_IN_AIR = false;
    this.IN_AIR = false;
    this.NEAR_WALL = false;
    this.wallN = new vec2(0, 0);
    this.floorN = new vec2(0, -1);
    this.fcount = 1;
    this.fvec = new vec2();
    this.raggy = new Ragdoll();
    this.ninja_gfx = null;
    this.crush_threshold = 0.05;
    this.crush_vec = new vec2();
    this.crush_dist = 0;
    this.crush_flag = false;
    this.death_type = sim_globals.DEATHTYPE_TIME;
    this.death_pos = new vec2();
    this.death_force = new vec2();
    this.TEMP_near_pos = new vec2();
    this.objList = [];
    this.segList = [];
    this.seg_cp = new vec2();
    this.wallList_X = [];
    this.wallList_Y = [];
    this.result_logical = new collision_result_logical();
    this.result_physical = new collision_result_physical();
    this.cp = new vec2();
    this.tempV = new vec2();
    this.tempP = new vec2();
    this.public_pos = new vec2();
    this.public_vel = new vec2();
  }
  DEBUG_SetPosVel(pos, vel) {
    if (this.curState === Ninja.PSTATE_DEAD) this.raggy.TESTING_SetPosVel(pos, vel);
    else { this.pos.Copy(pos); this.vel.Copy(vel); }
  }
  DEBUG_Respawn(pos) {
    this.curState = Ninja.PSTATE_STANDING;
    this.pos.x = pos.x; this.pos.y = pos.y;
    this.vel.x = 0; this.vel.y = 0;
    this.g = this.normGrav; this.d = this.normDrag;
  }
  GetIndex() { return this.pID; }
  GetPos() { this.public_pos.Copy(this.pos); return this.public_pos; }
  GetVel() { this.public_vel.Copy(this.vel); return this.public_vel; }
  GetRadius() { return this.r; }
  IsDead() { return this.curState === Ninja.PSTATE_DEAD || this.curState === Ninja.PSTATE_DISABLED; }
  DEBUG_GetRagdoll() { return this.raggy; }
  APP_Enable() { this.curState = Ninja.PSTATE_STANDING; }
  APP_Disable() { this.curState = Ninja.PSTATE_DISABLED; }

  Integrate() {
    if (this.curState === Ninja.PSTATE_DISABLED) return;
    if (this.curState === Ninja.PSTATE_DEAD) { this.raggy.Integrate(this.normGrav); return; }
    this.vel.x *= this.d;
    this.vel.y *= this.d;
    this.vel.y += this.g;
    this.pos.x += this.vel.x;
    this.pos.y += this.vel.y;
  }
  PreCollision() {
    if (this.curState === Ninja.PSTATE_DISABLED) return;
    if (this.curState === Ninja.PSTATE_DEAD) { this.raggy.PreCollision(); return; }
    this.oldv.x = this.vel.x;
    this.oldv.y = this.vel.y;
    this.fcount = 0;
    this.fvec.x = 0; this.fvec.y = 0;
    this.crush_vec.x = 0; this.crush_vec.y = 0;
    this.crush_dist = 0;
    this.crush_flag = false;
  }
  SolveInternalConstraints() {
    if (this.curState === Ninja.PSTATE_DEAD) this.raggy.SolveConstraints();
  }
  PostCollision(sim) {
    if (this.curState === Ninja.PSTATE_DISABLED) return;
    if (this.curState === Ninja.PSTATE_DEAD) { this.raggy.PostCollision(sim); return; }
    this.oldpos.Copy(this.pos);
    const skin = 0.1;
    this.wallList_X.length = 0;
    this.wallList_Y.length = 0;
    this.result_logical.Clear();
    sim.objGrid.GatherCellContentsInNeighbourhood(this.pos, this.objList);
    for (const ent of this.objList) {
      if (ent.CollideVsCircle_Logical(sim, this, this.result_logical, this.pos, this.vel, this.oldpos, this.r, skin)) {
        if (this.result_logical.vec_y === 0) {
          this.wallList_X.push(this.result_logical.vec_x);
          this.wallList_Y.push(this.result_logical.vec_y);
        }
      }
    }
    const reach = this.r + skin;
    sim.segGrid.GatherCellContentsFromWorldspaceRegion(
      this.pos.x - reach, this.pos.y - reach, this.pos.x + reach, this.pos.y + reach, this.segList);
    for (const s of this.segList) {
      s.GetClosestPoint(this.pos, this.seg_cp);
      let dx = this.pos.x - this.seg_cp.x;
      let dy = this.pos.y - this.seg_cp.y;
      const len = Math.sqrt(dx * dx + dy * dy);
      if (dy === 0 && len <= reach && len !== 0) {
        dx *= 1 / len; dy *= 1 / len;
        this.wallList_X.push(dx);
        this.wallList_Y.push(dy);
      }
    }
    this.WAS_IN_AIR = this.IN_AIR;
    this.IN_AIR = true;
    this.NEAR_WALL = false;
    if (this.wallList_X.length > 0) {
      this.NEAR_WALL = true;
      this.wallN.x = this.wallList_X[0];
      this.wallN.y = 0;
    }
    if (this.fcount > 0) {
      this.IN_AIR = false;
      const l = this.fvec.Len();
      if (l === 0) { this.floorN.x = 0; this.floorN.y = -1; }
      else { this.floorN.x = this.fvec.x / l; this.floorN.y = this.fvec.y / l; }
      if (this.WAS_IN_AIR) {
        let vn = this.oldv.x * this.floorN.x + this.oldv.y * this.floorN.y;
        vn = vn - 2 * Math.abs(this.floorN.y) * this.impulse_scale;
        if (vn < -this.terminal_vel) {
          this.vel.Copy(this.oldv);
          sim.Event_PlayerWasKilled(this, sim_globals.ENEMYTYPE_FALL, this.pos.x, this.pos.y, 0, 0);
        }
      }
    }
    if (this.crush_flag && this.crush_dist > 0) {
      const l = this.crush_vec.Len();
      const ratio = l / this.crush_dist;
      if (ratio < this.crush_threshold) {
        sim.Event_PlayerWasKilled(this, sim_globals.ENEMYTYPE_CRUSH, this.pos.x, this.pos.y, 0, 0);
      }
    }
  }
  RespondToCollision(nx, ny, pen, hard, crush) {
    this.pos.x += pen * nx;
    this.pos.y += pen * ny;
    if (crush) this.crush_flag = true;
    if (hard || crush) {
      this.crush_vec.x += pen * nx;
      this.crush_vec.y += pen * ny;
      this.crush_dist += Math.abs(pen);
    }
    if (hard) {
      const vn = this.vel.x * nx + this.vel.y * ny;
      if (vn < 0) { this.vel.x -= vn * nx; this.vel.y -= vn * ny; }
    } else {
      this.vel.x += pen * nx;
      this.vel.y += pen * ny;
    }
    if (ny < 0) {
      this.fcount++;
      this.fvec.x += nx;
      this.fvec.y += ny;
    }
  }
  CollideVsObjects(sim) {
    if (this.curState === Ninja.PSTATE_DEAD) { this.raggy.CollideVsObjects(sim); return; }
    this.result_physical.Clear();
    sim.objGrid.GatherCellContentsInNeighbourhood(this.pos, this.objList);
    for (const ent of this.objList) {
      if (ent.CollideVsCircle_Physical(this.result_physical, this.pos, this.vel, this.oldpos, this.r)) {
        const crush = ent instanceof Entity_Thwomp;
        this.RespondToCollision(this.result_physical.nx, this.result_physical.ny,
          this.result_physical.pen, this.result_physical.isHardCollision, crush);
      }
    }
  }
  CollideVsTiles(sim) {
    if (this.curState === Ninja.PSTATE_DEAD) { this.raggy.CollideVsTiles(sim); return; }
    const maxIter = 32;
    let iter = 0;
    this.cp.x = 0; this.cp.y = 0;
    while (true) {
      const sign = colutils.GetSingleClosestPoint_Signed(sim.segGrid, this.pos, this.r, this.cp);
      if (sign === 0) break;
      let dx = this.pos.x - this.cp.x;
      let dy = this.pos.y - this.cp.y;
      const len = Math.sqrt(dx * dx + dy * dy);
      const pen = this.r - sign * len;
      if (pen < 1e-7) break;
      if (len === 0) return;
      dx /= len; dy /= len;
      this.RespondToCollision(dx, dy, sign * pen, true, false);
      iter++;
      if (iter >= maxIter) break;
    }
  }

  Think(sim, frame) {
    this.inputsource.Tick(frame);
    const right = this.inputsource.IsButtonDown_Right();
    const left = this.inputsource.IsButtonDown_Left();
    const jump = this.inputsource.IsButtonDown_Jump();
    const jumpPressed = jump && !this.wasJdown;
    this.wasJdown = jump;
    if (this.curState === Ninja.PSTATE_DISABLED) return;
    if (this.curState === Ninja.PSTATE_DEAD) return;
    if (this.curState === Ninja.PSTATE_AWAITINGDEATH) {
      let pose = null, poseVel = null;
      if (this.ninja_gfx !== null && this.ninja_gfx.hasValidPose) {
        pose = new Array(6); poseVel = new Array(6);
        this.ninja_gfx.NINJA_GetCurrentPose(pose, poseVel);
      }
      this.raggy.ActivateRagdoll(this.pos, this.vel, this.death_pos, this.death_force, pose, poseVel);
      if (this.death_type === sim_globals.DEATHTYPE_EXPLOSIVE || this.death_type === sim_globals.DEATHTYPE_SUICIDE)
        this.raggy.ExplodeRagdoll(sim);
      sim.HACKY_GetParticleManager().Spawn_BloodSpurt(this.death_pos.x, this.death_pos.y,
        this.death_force.x, this.death_force.y, 3 + Math.floor(Math.random() * 4));
      const flip = Math.random() < 0.5;
      if (this.death_type === sim_globals.DEATHTYPE_EXPLOSIVE)
        this.ninja_gfx.HACKY_PlayOneshotSound(flip ? "explode1" : "explode2");
      else if (this.death_type === sim_globals.DEATHTYPE_FALL)
        this.ninja_gfx.HACKY_PlayOneshotSound("fall");
      else if (this.death_type === sim_globals.DEATHTYPE_LASER)
        this.ninja_gfx.HACKY_PlayOneshotSound("laser");
      else if (this.death_type === sim_globals.DEATHTYPE_ELECTRIC)
        this.ninja_gfx.HACKY_PlayOneshotSound(flip ? "zap1" : "zap2");
      else
        this.ninja_gfx.HACKY_PlayOneshotSound(flip ? "shot1" : "shot2");
      this.curState = Ninja.PSTATE_DEAD;
      return;
    }
    if (this.curState === Ninja.PSTATE_CELEBRATING) {
      if (this.IN_AIR) this.d = this.normDrag;
      else this.d = this.winDrag;
      return;
    }
    this.tempV.x = 0; this.tempV.y = 0;
    this.tempP.x = 0; this.tempP.y = 0;
    let vx = this.vel.x;
    let vy = this.vel.y;
    let move = 0;
    if (left) move--;
    if (right) move++;
    if (this.IN_AIR) {
      this.tempV.Copy(this.vel);
      const nvx = vx + move * this.airAccel;
      if (Math.abs(nvx) < this.maxspeedAir) vx = nvx;
      this.vel.x = vx;
      if (this.curState < 3) { this.ACTION_Fall(); return; }
      if (this.curState === Ninja.PSTATE_JUMPING) {
        this.jumptimer++;
        if (!jump || this.jumptimer > this.max_jump_time) { this.ACTION_Fall(); return; }
        return;
      }
      if (this.NEAR_WALL) {
        if (jumpPressed) {
          let ax, ay;
          if (this.curState === Ninja.PSTATE_WALLSLIDING && move * this.wallN.x < 0) { ax = 1; ay = 0.5; }
          else { ax = 1.5; ay = 0.7; }
          sim.HACKY_GetParticleManager().Spawn_JumpDust(this.pos.x - this.wallN.x * this.r,
            this.pos.y - this.wallN.y * this.r, this.wallN.x * 90);
          this.ACTION_Jump(this.wallN.x * ax, this.wallN.y - ay);
          return;
        }
        if (this.curState === Ninja.PSTATE_WALLSLIDING) {
          if (move * this.wallN.x > 0) { this.ACTION_Fall(); return; }
          const speed = Math.abs(vy);
          this.tempV.Copy(this.vel);
          this.vel.y *= this.wallFriction;
          sim.HACKY_GetParticleManager().Spawn_WallDust(this.pos, this.r, this.wallN, Math.min(4, speed));
          return;
        }
        if (vy > 0 && move * this.wallN.x < 0) { this.ACTION_Wallslide(); return; }
      } else if (this.curState === Ninja.PSTATE_WALLSLIDING) {
        this.ACTION_Fall(); return;
      }
    } else {
      this.tempV.Copy(this.vel);
      const nvx = vx + move * this.groundAccel;
      if (Math.abs(nvx) < this.maxspeedGround) vx = nvx;
      this.vel.x = vx;
      if (this.curState > 2) {
        sim.HACKY_GetParticleManager().Spawn_LandDust(
          this.pos.x - this.floorN.x * this.r, this.pos.y - this.floorN.y * this.r,
          90 + Math.atan2(this.floorN.y, this.floorN.x) / Math.PI * 180,
          Math.abs(this.vel.x) + this.vel.y);
        this.ninja_gfx.HACKY_PlayOneshotSound("land");
        if (vx * move > 0) { this.ACTION_Run(move); return; }
        this.ACTION_Skid(); return;
      }
      if (jumpPressed) {
        sim.HACKY_GetParticleManager().Spawn_JumpDust(
          this.pos.x - this.floorN.x * this.r, this.pos.y - this.floorN.y * this.r,
          90 + Math.atan2(this.floorN.y, this.floorN.x) / Math.PI * 180);
        if (move * this.floorN.x < 0) { this.ACTION_Jump(0, -0.7); return; }
        this.ACTION_Jump(this.floorN.x, this.floorN.y); return;
      }
      if (this.curState !== Ninja.PSTATE_RUNNING) {
        if (this.curState === Ninja.PSTATE_SKIDDING) {
          const fnx = this.floorN.x, fny = this.floorN.y;
          const along = Math.abs(vx * -fny + vy * fnx);
          const dirv = vx * along;
          if (dirv * move > 0) { this.ACTION_Run(move); return; }
          if (along < 0.1 && this.floorN.x === 0) { this.ACTION_Stand(); return; }
          let dir = 1;
          if (dirv < 0) dir = -1;
          const angle = Math.atan2(this.floorN.x, -this.floorN.y) * (180 / Math.PI);
          sim.HACKY_GetParticleManager().Spawn_FloorDust(this.pos, this.r, this.floorN, angle, dir, along);
          this.tempV.Copy(this.vel);
          if (vy < 0 && this.floorN.x !== 0) {
            const loss = Math.abs(vx * this.skidFriction - vx);
            let verticalLoss = Math.abs(loss * this.floorN.y);
            verticalLoss *= this.floorN.y * this.floorN.y;
            const len = Math.sqrt(vx * vx + vy * vy);
            const newLen = len - verticalLoss;
            vx /= len; vy /= len; vx *= newLen; vy *= newLen;
          } else vx *= this.skidFriction;
          this.vel.x = vx; this.vel.y = vy;
          return;
        }
        if (move !== 0) { this.ACTION_Run(move); return; }
        const along = Math.abs(vx * -this.floorN.y + vy * this.floorN.x);
        if (along >= 0.1) { this.ACTION_Skid(); return; }
        this.tempV.Copy(this.vel);
        vx *= this.standFriction;
        this.vel.x = vx; this.vel.y = vy;
        return;
      }
      const fnx = this.floorN.x, fny = this.floorN.y;
      const along = vx * -fny + vy * fnx;
      const absAlong = Math.abs(along);
      const dirv = vx * absAlong;
      if (move * dirv <= 0) { this.ACTION_Skid(); return; }
      if (move * fnx < 0) {
        let ax = -Math.abs(fnx);
        let ay = fny;
        if (fnx < 0) ay = -fny;
        const comp = Math.abs(fny);
        ay *= 0.5 * comp;
        ax *= 0.5 * comp;
        const slopeVx = vx + ay * this.groundAccel;
        const slopeVy = vy + ax * this.groundAccel;
        // NB: the original clips against the *straight-ahead* acceleration
        // candidate (_loc18_), not the slope-adjusted one.
        if (Math.abs(nvx) < this.maxspeedGround) { vx = slopeVx; vy = slopeVy; }
        this.tempV.Copy(this.vel);
        this.vel.x = vx; this.vel.y = vy;
      }
    }
  }
  DEATHMATCH_IsInAir() { return this.IN_AIR; }
  DEATHMATCH_Jump(a) { this.ACTION_Jump(0, a); }
  ACTION_Jump(x, y) {
    this.HELPER_ExitCurrentState();
    this.curState = Ninja.PSTATE_JUMPING;
    this.g = this.jumpGrav;
    if (this.vel.x * x < 0) this.vel.x = 0;
    if (this.vel.y * y < 0) this.vel.y = 0;
    this.pos.x += x * this.jumpAmt * this.impulse_scale;
    this.pos.y += y * (this.jumpAmt + this.jump_y_bias) * this.impulse_scale;
    this.vel.x += x * this.jumpAmt * this.impulse_scale;
    this.vel.y += y * (this.jumpAmt + this.jump_y_bias) * this.impulse_scale;
    this.jumptimer = 0;
    this.ninja_gfx.HACKY_PlayOneshotSound("jump");
  }
  ACTION_Fall() { this.HELPER_ExitCurrentState(); this.curState = Ninja.PSTATE_FALLING; }
  ACTION_Wallslide() { this.HELPER_ExitCurrentState(); this.curState = Ninja.PSTATE_WALLSLIDING; }
  ACTION_Skid() { this.HELPER_ExitCurrentState(); this.curState = Ninja.PSTATE_SKIDDING; }
  ACTION_Run() { this.HELPER_ExitCurrentState(); this.curState = Ninja.PSTATE_RUNNING; }
  ACTION_Stand() { this.HELPER_ExitCurrentState(); this.curState = Ninja.PSTATE_STANDING; }
  ACTION_Die() { this.HELPER_ExitCurrentState(); this.curState = Ninja.PSTATE_AWAITINGDEATH; }
  ACTION_Win() { this.HELPER_ExitCurrentState(); this.curState = Ninja.PSTATE_CELEBRATING; }
  HELPER_ExitCurrentState() {
    if (this.curState === Ninja.PSTATE_JUMPING) this.g = this.normGrav;
  }
  SIM_Launch(x, y) {
    if (this.curState === Ninja.PSTATE_AWAITINGDEATH) return;
    this.pos.x += x * this.impulse_scale;
    this.pos.y += y * this.impulse_scale;
    this.vel.x = x * this.impulse_scale;
    this.vel.y = y * this.impulse_scale;
    this.fcount = 0;
    if (this.curState !== Ninja.PSTATE_CELEBRATING) this.ACTION_Fall();
  }
  SIM_Kill(enemyType, x, y, fx, fy) {
    if (this.curState === Ninja.PSTATE_AWAITINGDEATH || this.curState === Ninja.PSTATE_DISABLED) return false;
    this.death_pos.x = x; this.death_pos.y = y;
    this.death_force.x = fx; this.death_force.y = fy;
    this.death_type = sim_globals.ETYPE_TO_DTYPE[enemyType];
    this.ACTION_Die();
    return true;
  }
  SIM_Win() {
    if (this.curState === Ninja.PSTATE_DISABLED || this.curState === Ninja.PSTATE_CELEBRATING ||
        this.curState === Ninja.PSTATE_AWAITINGDEATH || this.curState === Ninja.PSTATE_DEAD) return false;
    this.ACTION_Win();
    return true;
  }
  GenerateGraphicComponent() {
    this.ninja_gfx = new EntityGraphics_Ninja(this, this.gfxColor);
    return this.ninja_gfx;
  }
  GFX_UpdateState(gfx) {
    if (this.curState === Ninja.PSTATE_DISABLED) { gfx.anim = EntityGraphics_Ninja.ANIM_OFF; return; }
    if (this.curState === Ninja.PSTATE_DEAD) {
      gfx.anim = EntityGraphics_Ninja.ANIM_DEAD;
      this.raggy.GFX_UpdateState(gfx);
      return;
    }
    gfx.pos.x = this.pos.x; gfx.pos.y = this.pos.y;
    if (this.curState === Ninja.PSTATE_WALLSLIDING) {
      gfx.anim = EntityGraphics_Ninja.ANIM_WALLSLIDING;
      gfx.orn = 0;
      gfx.facing = -this.wallN.x;
      gfx.vel = this.vel.y;
    } else {
      if (this.IN_AIR) {
        gfx.anim = EntityGraphics_Ninja.ANIM_INAIR;
        gfx.vel = this.vel.y;
        if (this.curState === Ninja.PSTATE_JUMPING) gfx.orn = 0;
        else gfx.orn -= 0.1 * gfx.orn;
      } else {
        gfx.orn = Math.atan2(this.floorN.y, this.floorN.x) + 0.5 * Math.PI;
        if (this.curState === Ninja.PSTATE_RUNNING) {
          gfx.anim = EntityGraphics_Ninja.ANIM_RUNNING;
          gfx.vel = Math.abs(this.vel.x * -this.floorN.y + this.vel.y * this.floorN.x);
        } else if (this.curState === Ninja.PSTATE_SKIDDING) {
          gfx.anim = EntityGraphics_Ninja.ANIM_SKIDDING;
          gfx.vel = this.vel.x * -this.floorN.y + this.vel.y * this.floorN.x;
        } else if (this.curState === Ninja.PSTATE_STANDING) {
          gfx.anim = EntityGraphics_Ninja.ANIM_STANDING;
        } else if (this.curState === Ninja.PSTATE_CELEBRATING) {
          gfx.anim = EntityGraphics_Ninja.ANIM_CELEBRATING;
        }
      }
      if (this.vel.x < -0.01) gfx.facing = -1;
      else if (this.vel.x > 0.01) gfx.facing = 1;
    }
  }
  Draw() {}
}
