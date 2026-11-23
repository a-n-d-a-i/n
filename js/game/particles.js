/* Literal port of audiovisual/ParticleManager*.as */
import { Sprite, MovieClip } from "../flash.js";
import { vec2 } from "./math.js";
import * as A from "../assets.js";

const MAX_PARTICLE_SCALE = 64;
const MAX_PARTICLES = 100;

const mcList = [
  [A.asset_gfx_fx_dust0, A.asset_gfx_fx_dust1],
  [A.asset_gfx_fx_dust0, A.asset_gfx_fx_dust1],
  [A.asset_gfx_fx_blood0, A.asset_gfx_fx_blood1],
  [A.asset_gfx_fx_dust0, A.asset_gfx_fx_dust1],
  [A.asset_gfx_fx_chain_bullet],
  [A.asset_gfx_fx_chain_debris0, A.asset_gfx_fx_chain_debris1, A.asset_gfx_fx_chain_debris2],
  [A.asset_gfx_fx_chain_flash0, A.asset_gfx_fx_chain_flash1],
  [A.asset_gfx_fx_laser_spark0, A.asset_gfx_fx_laser_spark1, A.asset_gfx_fx_laser_spark2],
  [A.asset_gfx_fx_laser_charge0, A.asset_gfx_fx_laser_charge1, A.asset_gfx_fx_laser_charge2],
  [A.asset_gfx_fx_zap0, A.asset_gfx_fx_zap1, A.asset_gfx_fx_zap2],
  [A.asset_gfx_fx_zapv0, A.asset_gfx_fx_zapv1, A.asset_gfx_fx_zapv2],
  [A.asset_gfx_fx_turret_bullet],
  [A.asset_gfx_fx_turret_debris0],
  [A.asset_gfx_fx_fireburst0, A.asset_gfx_fx_fireburst1],
  [A.asset_gfx_fx_fireball0, A.asset_gfx_fx_fireball1, A.asset_gfx_fx_fireball2],
  [A.asset_gfx_fx_rocket_smoke0, A.asset_gfx_fx_rocket_smoke1, A.asset_gfx_fx_rocket_smoke2],
];
const bufferList = [0, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1];

export class ParticleManager_Classic {
  static FXTYPE_SKIDDUST = 0;
  constructor(back, front) {
    this.buffers = [back, front];
  }
  SpawnParticle_Random(type, chance) {
    return Math.random() <= chance ? this.SpawnParticle(type) : null;
  }
  SpawnParticle(type) {
    const cls = mcList[type][Math.floor(Math.random() * mcList[type].length)];
    const mc = new cls();
    this.buffers[bufferList[type]].addChild(mc);
    return mc;
  }
  SpawnParticle_Limit(type) {
    return this.buffers[bufferList[type]].numChildren < MAX_PARTICLES ? this.SpawnParticle(type) : null;
  }
  Spawn_FloorDust(pos, radius, n, angle, dir, speed) {
    const mc = this.SpawnParticle_Random(0, 0.2);
    if (mc) {
      mc.x = pos.x - n.x * radius;
      mc.y = pos.y - n.y * radius;
      mc.rotation = angle - dir * 8 + (Math.random() * 10 - 5);
      mc.scaleX = Math.min(64, dir * Math.min(MAX_PARTICLE_SCALE, 10 + speed * 10) / 100);
      mc.scaleY = 0.1;
    }
  }
  Spawn_WallDust(pos, radius, n, speed) {
    const mc = this.SpawnParticle_Random(0, 0.3);
    if (mc) {
      mc.x = pos.x - n.x * radius;
      mc.y = pos.y - n.y * radius - (Math.random() * radius * 2 - radius);
      mc.rotation = 90 - n.x * 8 + (Math.random() * 10 - 5);
      mc.scaleX = Math.min(MAX_PARTICLE_SCALE, 10 + speed * 20) / 100;
      mc.scaleY = 0.1;
    }
  }
  Spawn_JumpDust(x, y, angle) {
    let dir = 1;
    for (let i = 0; i <= 4; i++) {
      const mc = this.SpawnParticle(1);
      mc.x = x; mc.y = y;
      mc.rotation = angle - dir * 20 + (Math.random() * 20 - 10);
      mc.scaleX = dir * (10 + Math.random() * 8) / 100;
      mc.scaleY = (10 + Math.random() * 5) / 100;
      dir *= -1;
    }
  }
  Spawn_LandDust(x, y, angle, speed) {
    let dir = 1;
    for (let i = 0; i <= 4; i++) {
      const mc = this.SpawnParticle(1);
      mc.x = x; mc.y = y;
      mc.rotation = angle - dir * 40 + (Math.random() * 20 - 10);
      mc.scaleX = dir * (5 + Math.random() * 5 + speed) / 100;
      mc.scaleY = (15 + speed * 2) / 100;
      dir *= -1;
    }
  }
  Spawn_BloodSpurt(x, y, fx, fy, n) {
    for (let i = 0; i <= n; i++) {
      const mc = this.SpawnParticle_Limit(2);
      if (!mc) continue;
      mc.x = x - (Math.random() * 8 - 4);
      mc.y = y - (Math.random() * 8 - 4);
      mc.scaleX = Math.min(64, Math.max(-64, fx * (6 + Math.random() * 3) - (Math.random() * 60 - 30))) / 100;
      mc.scaleY = Math.min(64, Math.max(-64, fy * (6 + Math.random() * 3) - (Math.random() * 60 - 30))) / 100;
    }
  }
  Spawn_RagBloodSpurt(x, y, fx, fy) {
    const mc = this.SpawnParticle_Limit(2);
    if (mc) {
      mc.x = x - (Math.random() * 8 - 4);
      mc.y = y - (Math.random() * 8 - 4);
      mc.scaleX = Math.min(64, Math.max(-64, fx * (6 + Math.random() * 3) - (Math.random() * 40 - 20))) / 100;
      mc.scaleY = Math.min(64, Math.max(-64, fy * (6 + Math.random() * 3) - (Math.random() * 40 - 20))) / 100;
    }
  }
  Spawn_RagDust(pos, radius, dx, dy, len) {
    const mc = this.SpawnParticle_Random(3, 0.2);
    if (mc) {
      const nx = dx / len, ny = dy / len;
      mc.x = pos.x - nx * radius;
      mc.y = pos.y - ny * radius;
      mc.rotation = Math.atan2(ny, nx) / Math.PI * 180 + (Math.random() * 20 - 10);
      mc.scaleX = Math.min(64, 20 + 2 * len) / 100;
      mc.scaleY = 0.1;
    }
  }
  Spawn_RocketSmoke(pos, angle) {
    const mc = this.SpawnParticle_Random(15, 0.2);
    if (mc) {
      mc.x = pos.x; mc.y = pos.y;
      mc.rotation = angle + 10 * (Math.random() * 2 - 1);
      mc.scaleX = (20 + Math.random() * 20) / 100;
      mc.scaleY = (20 + Math.random() * 20) / 100;
    }
  }
  Spawn_Explosion(pos) {
    const a = this.SpawnParticle(13);
    const b = this.SpawnParticle(14);
    const c = this.SpawnParticle(14);
    const d = this.SpawnParticle(14);
    const e = this.SpawnParticle(14);
    for (const mc of [a, b, c, d, e]) { mc.x = pos.x; mc.y = pos.y; }
    const r1 = Math.random(), r2 = Math.random(), r3 = Math.random(), r4 = Math.random(), r5 = Math.random();
    a.scaleX = (15 + r1 * 15) / 100;
    a.scaleY = (15 + r2 * 15) / 100;
    b.scaleX = c.scaleX = (20 + r3 * 20) / 100;
    d.scaleX = e.scaleX = (20 + r4 * 30) / 100;
    b.scaleY = e.scaleY = (20 + r5 * 20) / 100;
    c.scaleY = d.scaleY = (20 + r1 * 10) / 100;
    b.rotation = 360 * r1;
    c.rotation = 360 * r2;
    d.rotation = 360 * r5;
    e.rotation = 360 * r3;
  }
  Spawn_TurretBullet(a, b) {
    const bullet = this.SpawnParticle(11);
    bullet.x = a.x; bullet.y = a.y;
    bullet.scaleX = (b.x - a.x) / 100;
    bullet.scaleY = (b.y - a.y) / 100;
    const d1 = this.SpawnParticle(12);
    const d2 = this.SpawnParticle(12);
    d1.x = d2.x = b.x; d1.y = d2.y = b.y;
    d1.scaleX = d2.scaleY = (40 + Math.random() * 20) / 100;
    d2.scaleX = d1.scaleY = (20 + Math.random() * 40) / 100;
    const ang = Math.atan2(a.y - b.y, a.x - b.x) / Math.PI * 180;
    d1.rotation = ang + (5 + Math.random() * 15);
    d2.rotation = ang - (5 + Math.random() * 15);
  }
  Spawn_LaserSpark(pos, dx, dy) {
    const mc = this.SpawnParticle_Random(7, 0.75);
    if (mc) {
      mc.x = pos.x; mc.y = pos.y;
      mc.scaleX = -dx * (30 + 40 * (Math.random() * 2 - 1)) / 100;
      mc.scaleY = -dy * (30 + 40 * (Math.random() * 2 - 1)) / 100;
    }
  }
  Spawn_LaserCharge(pos) {
    const mc = this.SpawnParticle_Random(8, 0.9);
    if (mc) {
      mc.x = pos.x; mc.y = pos.y;
      mc.scaleX = (20 + Math.random() * 20) / 100;
      mc.scaleY = (10 + Math.random() * 20) / 100;
      mc.rotation = Math.random() * 360;
    }
  }
  Spawn_Zap(x, y, angle) {
    for (let i = 0; i <= 4; i++) {
      const mc = this.SpawnParticle_Limit(9);
      if (!mc) continue;
      mc.x = x; mc.y = y;
      mc.scaleX = (30 + Math.random() * 30) / 100;
      mc.scaleY = (30 + Math.random() * 20) / 100;
      mc.rotation = angle + 20 * (Math.random() * 2 - 1);
    }
  }
  Spawn_ZapThwompH(pos, dx, dy) {
    for (let i = 0; i <= 4; i++) {
      const mc = this.SpawnParticle_Limit(9);
      if (!mc) continue;
      mc.x = pos.x + dx;
      mc.y = pos.y - dy + dy * Math.random();
      mc.scaleX = (4 * dx + 20 * (Math.random() * 2 - 1)) / 100;
      mc.scaleY = (60 + 60 * Math.random()) / 100;
    }
  }
  Spawn_ZapThwompV(pos, dx, dy) {
    for (let i = 0; i <= 4; i++) {
      const mc = this.SpawnParticle_Limit(10);
      if (!mc) continue;
      mc.y = pos.y + dy;
      mc.x = pos.x - dx + dx * Math.random();
      mc.scaleY = (4 * dy + 20 * (Math.random() * 2 - 1)) / 100;
      mc.scaleX = (60 + 60 * Math.random()) / 100;
    }
  }
  Spawn_ChainBullet(a, b) {
    const r1 = Math.random() * 2 - 1;
    const r2 = Math.random() * 2 - 1;
    const r3 = Math.random() * 2 - 1;
    const flash = this.SpawnParticle(6);
    const bullet = this.SpawnParticle(4);
    const dx = b.x - a.x, dy = b.y - a.y;
    const len = Math.sqrt(dx * dx + dy * dy);
    let ang = Math.atan2(dy, dx) / Math.PI * 180;
    bullet.scaleX = len / 100;
    flash.x = bullet.x = a.x; flash.y = bullet.y = a.y;
    flash.scaleX = (30 + r1 * 10) / 100;
    flash.scaleY = (20 + r2 * 20) / 100;
    flash.rotation = bullet.rotation = ang;
    const d1 = this.SpawnParticle(5);
    const d2 = this.SpawnParticle(5);
    d1.x = d2.x = b.x; d1.y = d2.y = b.y;
    d1.scaleX = (30 + 15 * r2) / 100;
    d2.scaleX = (30 + 15 * r3) / 100;
    ang -= 180;
    d1.rotation = ang + 15 * r1;
    d2.rotation = ang + 15 * r2;
  }
}

export class ParticleManager_Null {
  Spawn_FloorDust() {} Spawn_WallDust() {} Spawn_JumpDust() {} Spawn_LandDust() {}
  Spawn_BloodSpurt() {} Spawn_RagBloodSpurt() {} Spawn_RagDust() {} Spawn_RocketSmoke() {}
  Spawn_Explosion() {} Spawn_TurretBullet() {} Spawn_LaserSpark() {} Spawn_LaserCharge() {}
  Spawn_Zap() {} Spawn_ZapThwompH() {} Spawn_ZapThwompV() {} Spawn_ChainBullet() {}
}
