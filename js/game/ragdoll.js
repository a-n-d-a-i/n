/* Literal port of simulation/ninja/Ragdoll.as (including RagParticle/RagStick). */
import { vec2, mathutils } from "./math.js";
import { colutils } from "./collision.js";
import { Entity_Mine, Entity_Drone_Zap, Entity_FloorGuard, Entity_Thwomp,
         collision_result_logical, collision_result_physical } from "./entities.js";

const pRadius = [2.49, 2.49, 1.99, 1.99, 2.99, 2.99];
const pDrag = [0.99, 0.995, 0.995, 0.99, 0.99, 0.995];
const sWeight = [0.4, 0.2, 0.26, 0.32, 0.37];
const sMinRatio = [0.8, 0.6, 0.6, 0.6, 0.6];
const hacky_scale = 0.2;
const sMaxLen = [30 * hacky_scale, 40 * hacky_scale, 40 * hacky_scale, 60 * hacky_scale, 60 * hacky_scale];
const debugpose_pos = [
  new vec2(0, -sMaxLen[0]), new vec2(0, 0), new vec2(sMaxLen[1], -sMaxLen[0]),
  new vec2(-sMaxLen[2], -sMaxLen[0]),
  new vec2(Math.SQRT1_2 * sMaxLen[3], Math.SQRT1_2 * sMaxLen[3]),
  new vec2(Math.SQRT1_2 * -sMaxLen[4], Math.SQRT1_2 * sMaxLen[3]),
];
const debugpose_vel = [new vec2(), new vec2(), new vec2(), new vec2(), new vec2(), new vec2()];

class RagParticle {
  constructor(r, d) {
    this.pos = new vec2(); this.vel = new vec2(); this.solver_pos = new vec2();
    this.r = r; this.d = d;
  }
  PreIntegrate(g) {
    this.vel.x *= this.d; this.vel.y *= this.d; this.vel.y += g;
    this.solver_pos.x = this.pos.x + this.vel.x;
    this.solver_pos.y = this.pos.y + this.vel.y;
  }
  PostIntegrate() {
    this.vel.x = this.solver_pos.x - this.pos.x;
    this.vel.y = this.solver_pos.y - this.pos.y;
    this.pos.x = this.solver_pos.x; this.pos.y = this.solver_pos.y;
  }
  SetState(x, y, vx, vy) { this.pos.x = x; this.pos.y = y; this.vel.x = vx; this.vel.y = vy; }
  CopyState(o) { this.pos.Copy(o.pos); this.vel.Copy(o.vel); }
}
class RagStick {
  constructor(p0, p1, w0, minRatio, maxLen) {
    this.p0 = p0; this.p1 = p1; this.w0 = w0; this.w1 = 1 - w0;
    this.minlen = maxLen * minRatio; this.maxlen = maxLen;
  }
  Solve() {
    const dx = this.p1.solver_pos.x - this.p0.solver_pos.x;
    const dy = this.p1.solver_pos.y - this.p0.solver_pos.y;
    const len = Math.sqrt(dx * dx + dy * dy);
    if (this.minlen <= len && len <= this.maxlen) return;
    const target = Math.max(this.minlen, Math.min(this.maxlen, len));
    const diff = len - target;
    let ux = 1, uy = 0;
    if (len !== 0) { ux = dx / len; uy = dy / len; }
    this.p0.solver_pos.x -= this.w0 * -diff * ux;
    this.p0.solver_pos.y -= this.w0 * -diff * uy;
    this.p1.solver_pos.x += this.w1 * -diff * ux;
    this.p1.solver_pos.y += this.w1 * -diff * uy;
  }
}

export class Ragdoll {
  static STATE_UNEXPLODED = 0;
  static STATE_EXPLODED = 1;
  constructor() {
    this.cur_state = 0;
    this.explosion_accumulator = 0;
    this.pList = [[], []];
    for (let i = 0; i < 6; i++) this.pList[0][i] = new RagParticle(pRadius[i], pDrag[i]);
    for (let i = 0; i < 6; i++) this.pList[1][i] = new RagParticle(pRadius[i], pDrag[i]);
    for (let i = 0; i < 4; i++) this.pList[1][6 + i] = new RagParticle(
      [pRadius[0], pRadius[0], pRadius[1], pRadius[1]][i],
      [pDrag[0], pDrag[0], pDrag[1], pDrag[1]][i]);
    this.sList = [[], []];
    this.sList[0][0] = new RagStick(this.pList[0][1], this.pList[0][0], sWeight[0], sMinRatio[0], sMaxLen[0]);
    this.sList[0][1] = new RagStick(this.pList[0][0], this.pList[0][2], sWeight[1], sMinRatio[1], sMaxLen[1]);
    this.sList[0][2] = new RagStick(this.pList[0][0], this.pList[0][3], sWeight[2], sMinRatio[2], sMaxLen[2]);
    this.sList[0][3] = new RagStick(this.pList[0][1], this.pList[0][4], sWeight[3], sMinRatio[3], sMaxLen[3]);
    this.sList[0][4] = new RagStick(this.pList[0][1], this.pList[0][5], sWeight[4], sMinRatio[4], sMaxLen[4]);
    this.sList[1][0] = new RagStick(this.pList[1][1], this.pList[1][0], sWeight[0], sMinRatio[0], sMaxLen[0]);
    this.sList[1][1] = new RagStick(this.pList[1][6], this.pList[1][2], sWeight[1], sMinRatio[1], sMaxLen[1]);
    this.sList[1][2] = new RagStick(this.pList[1][7], this.pList[1][3], sWeight[2], sMinRatio[2], sMaxLen[2]);
    this.sList[1][3] = new RagStick(this.pList[1][8], this.pList[1][4], sWeight[3], sMinRatio[3], sMaxLen[3]);
    this.sList[1][4] = new RagStick(this.pList[1][9], this.pList[1][5], sWeight[4], sMinRatio[4], sMaxLen[4]);
    this.objList = [];
    this.result_logical = new collision_result_logical();
    this.result_physical = new collision_result_physical();
    this.cp = new vec2();
  }
  ActivateRagdoll(pos, vel, deathPos, deathForce, pose, poseVel) {
    this.cur_state = 0;
    this.explosion_accumulator = 0;
    let p, v;
    if (pose != null && poseVel != null) { p = pose; v = poseVel; }
    else { p = debugpose_pos; v = debugpose_vel; }
    for (let i = 0; i < 6; i++) {
      this.pList[0][i].SetState(pos.x + p[i].x, pos.y + p[i].y,
                                vel.x + v[i].x, vel.y + v[i].y);
    }
    this.ShoveRagdoll(deathPos, deathForce);
  }
  ShoveRagdoll(deathPos, force) {
    for (let i = 0; i < this.pList[0].length; i++) {
      const dx = this.pList[0][i].pos.x - deathPos.x;
      const dy = this.pList[0][i].pos.y - deathPos.y;
      const d = Math.sqrt(dx * dx + dy * dy);
      const k = 0.5 + (1 - Math.min(1, d / 12)) * 1.5;
      this.pList[0][i].vel.x += force.x * k;
      this.pList[0][i].vel.y += force.y * k;
    }
  }
  DEBUG_IsExploded() { return this.cur_state === 1; }
  ExplodeRagdoll(sim) {
    if (this.cur_state === 1) return;
    this.cur_state = 1;
    this.InitUnexplodedParticles();
    for (let i = 6; i < 10; i++) {
      const p = this.pList[1][i].pos;
      sim.HACKY_GetParticleManager().Spawn_BloodSpurt(p.x, p.y,
        Math.random() * 8 - 4, Math.random() * 8 - 4, 3);
    }
  }
  UnexplodeRagdoll() {
    if (this.cur_state === 0) return;
    this.cur_state = 0;
    for (let i = 0; i < 6; i++) this.pList[0][i].CopyState(this.pList[1][i]);
  }
  InitUnexplodedParticles() {
    for (let i = 0; i < 6; i++) this.pList[1][i].CopyState(this.pList[0][i]);
    this.pList[1][6].CopyState(this.pList[0][0]);
    this.pList[1][7].CopyState(this.pList[0][0]);
    this.pList[1][8].CopyState(this.pList[0][1]);
    this.pList[1][9].CopyState(this.pList[0][1]);
    this.pList[1][6].vel.x += 2;
    this.pList[1][7].vel.y += 4;
    this.pList[1][8].vel.y -= 6;
    this.pList[1][9].vel.x -= 8;
  }
  Integrate(g) {
    for (const p of this.pList[this.cur_state]) p.PreIntegrate(g);
  }
  PreCollision() {}
  SolveConstraints() {
    for (const s of this.sList[this.cur_state]) s.Solve();
  }
  PostCollision(sim) {
    // Re-read pList[cur_state] on every iteration: an explosion triggered
    // below switches the active list to the 10-particle exploded body.
    for (let i = 0; i < this.pList[this.cur_state].length; i++)
      this.pList[this.cur_state][i].PostIntegrate();
    const skin = 0.1;
    this.result_logical.Clear();
    for (let i = 0; i < this.pList[this.cur_state].length; i++) {
      const p = this.pList[this.cur_state][i];
      sim.objGrid.GatherCellContentsInNeighbourhood(p.pos, this.objList);
      for (const ent of this.objList) {
        if (ent.CollideVsCircle_Logical(sim, null, this.result_logical, p.pos, p.vel, p.pos, p.r, skin)) {
          p.vel.x += this.result_logical.vec_x;
          p.vel.y += this.result_logical.vec_y;
          if (ent instanceof Entity_Mine) {
            if (this.cur_state === 0) {
              this.explosion_accumulator += mathutils.Random() * 0.6;
              if (Math.random() < this.explosion_accumulator) this.ExplodeRagdoll(sim);
            }
          } else if (ent instanceof Entity_Drone_Zap || ent instanceof Entity_FloorGuard ||
                     ent instanceof Entity_Thwomp) {
            if (Math.random() < 0.5) sim.HACKY_GetSoundManager().PlaySound_Ragdoll("zap1");
            else sim.HACKY_GetSoundManager().PlaySound_Ragdoll("zap2");
          }
        }
      }
    }
  }
  CollideVsObjects(sim) {
    this.result_physical.Clear();
    for (const p of this.pList[this.cur_state]) {
      sim.objGrid.GatherCellContentsInNeighbourhood(p.solver_pos, this.objList);
      for (const ent of this.objList) {
        if (ent.CollideVsCircle_Physical(this.result_physical, p.solver_pos, p.vel, p.pos, p.r)) {
          this.RespondToCollision(sim, p, this.result_physical.nx, this.result_physical.ny, this.result_physical.pen);
        }
      }
    }
  }
  CollideVsTiles(sim) {
    for (const p of this.pList[this.cur_state]) {
      let iterations = 0;
      this.cp.x = 0; this.cp.y = 0;
      while (true) {
        const sign = colutils.GetSingleClosestPoint_Signed(sim.segGrid, p.solver_pos, p.r * 4, this.cp);
        if (sign === 0) break;
        let dx = p.solver_pos.x - this.cp.x;
        let dy = p.solver_pos.y - this.cp.y;
        const len = Math.sqrt(dx * dx + dy * dy);
        const pen = p.r - sign * len;
        if (pen < 1e-7) break;
        if (len === 0) return;
        dx /= len; dy /= len;
        this.RespondToCollision(sim, p, dx, dy, sign * pen);
        iterations++;
        if (iterations >= 32) break;
      }
    }
  }
  RespondToCollision(sim, p, nx, ny, pen) {
    p.solver_pos.x += pen * nx;
    p.solver_pos.y += pen * ny;
    let velScale = 0;
    let tangScale = 0.05;
    let posScale = 0;
    const dx = p.solver_pos.x - p.pos.x;
    const dy = p.solver_pos.y - p.pos.y;
    const vn = dx * nx + dy * ny;
    const vt = dx * -ny + dy * nx;
    if (vn < 0) {
      velScale = 2;
      tangScale = 0.15;
      posScale = 1;
      if (vn < -3) {
        sim.HACKY_GetParticleManager().Spawn_RagBloodSpurt(p.solver_pos.x, p.solver_pos.y, -vn * nx, -vn * ny);
        const r = Math.random();
        if (r < 0.33) sim.HACKY_GetSoundManager().PlaySound_Ragdoll("hard1");
        else if (r < 0.66) sim.HACKY_GetSoundManager().PlaySound_Ragdoll("hard2");
        else sim.HACKY_GetSoundManager().PlaySound_Ragdoll("hard3");
      } else {
        if (vt * vt > 0.7) sim.HACKY_GetParticleManager().Spawn_RagDust(p.solver_pos, p.r, vt * -ny, vt * nx, vt * vt);
        if (vn < -2) {
          if (Math.random() < 0.5) sim.HACKY_GetSoundManager().PlaySound_Ragdoll("med1");
          else sim.HACKY_GetSoundManager().PlaySound_Ragdoll("med2");
        } else if (vn < -1.2) {
          if (Math.random() < 0.5) sim.HACKY_GetSoundManager().PlaySound_Ragdoll("soft1");
          else sim.HACKY_GetSoundManager().PlaySound_Ragdoll("soft2");
        }
      }
    }
    p.pos.x += posScale * pen * nx + velScale * vn * nx + tangScale * vt * -ny;
    p.pos.y += posScale * pen * ny + velScale * vn * ny + tangScale * vt * nx;
  }
  GFX_UpdateState(gfx) {
    const sticks = this.sList[this.cur_state];
    for (let i = 0; i < sticks.length; i++) {
      const s = sticks[i];
      const dx = s.p1.pos.x - s.p0.pos.x;
      const dy = s.p1.pos.y - s.p0.pos.y;
      const len = Math.sqrt(dx * dx + dy * dy);
      gfx.ragdoll_posList[i].Copy(s.p0.pos);
      gfx.ragdoll_ornList[i] = Math.atan2(dy, dx);
      gfx.ragdoll_lenList[i] = Math.max(0, Math.min(1, len / s.maxlen));
    }
  }
  TESTING_SetPosVel(pos, vel) {
    this.pList[this.cur_state][0].pos.Copy(pos);
    this.pList[this.cur_state][0].vel.Copy(vel);
  }
  Draw() {}
}
