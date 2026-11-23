/* Literal port of math/vec2.as and math/mathutils.as */

export class vec2 {
  constructor(x = 0, y = 0) { this.x = x; this.y = y; }
  static FromDir(a) { return new vec2(Math.cos(a), Math.sin(a)); }
  static VecTo(a, b) { return new vec2(b.x - a.x, b.y - a.y); }
  VecPerp(a) { return new vec2(-a.y, a.x); }
  VecDot(a, b) { return a.x * b.x + a.y * b.y; }
  To(v) { return new vec2(v.x - this.x, v.y - this.y); }
  Perp() { return new vec2(-this.y, this.x); }
  PerpDot(v) { return -this.y * v.x + this.x * v.y; }
  Clone() { return new vec2(this.x, this.y); }
  Plus(v) { return new vec2(this.x + v.x, this.y + v.y); }
  Minus(v) { return new vec2(this.x - v.x, this.y - v.y); }
  Dot(v) { return this.x * v.x + this.y * v.y; }
  Len() { return Math.sqrt(this.x * this.x + this.y * this.y); }
  LenSq() { return this.x * this.x + this.y * this.y; }
  ToString() { return "(" + this.x + "," + this.y + ")"; }
  Copy(v) { this.x = v.x; this.y = v.y; }
  Normalize() {
    const l = Math.sqrt(this.x * this.x + this.y * this.y);
    if (l !== 0) { this.x /= l; this.y /= l; }
  }
  Scale(s) { this.x *= s; this.y *= s; }
}

export const mathutils = {
  rnd_seed: 1,
  SetRandomSeed(v) {
    v = v >>> 0;
    if (v === 0 || v > 2147483646) { this.rnd_seed = 1; }
    else this.rnd_seed = v;
  },
  GenerateNewRandomSeed() {
    this.SetRandomSeed(1 + ((Math.random() * 2147483645) >>> 0));
  },
  GetRandomSeed() { return this.rnd_seed; },
  Random() { return this._gen() / 2147483647; },
  _gen() {
    // AS3 arithmetic is double precision: the multiply is exact (well within
    // 2^53) and only the assignment back to the uint seed truncates.
    this.rnd_seed = (this.rnd_seed * 16807) % 2147483647;
    return this.rnd_seed;
  },
  DegToRad(d) { return d * (Math.PI / 180); },
  RadToDeg(r) { return r * (180 / Math.PI); },
  WrapAngle_Shortest(a) {
    while (Math.PI < Math.abs(a)) {
      if (a < 0) a += 2 * Math.PI; else a -= 2 * Math.PI;
    }
    return a;
  },
  WrapAngle_Directed(a, dir) {
    if (dir > 0) return this.WrapAngle_Pos(a);
    if (dir < 0) {
      while (a > 0 || a < -Math.PI * 2) {
        if (a > 0) a -= 2 * Math.PI;
        else if (-2 * Math.PI > a) a += 2 * Math.PI;
      }
      return a;
    }
    return 0;
  },
  WrapAngle_Pos(a) {
    while (a < 0 || a > Math.PI * 2) {
      if (a < 0) a += 2 * Math.PI;
      else if (2 * Math.PI < a) a -= 2 * Math.PI;
    }
    return a;
  },
  InterpolateOrn(a, b, t, dir = 0) {
    const p = this.WrapAngle_Pos(a), q = this.WrapAngle_Pos(b);
    let d = q - p;
    if (dir === 0) d = this.WrapAngle_Shortest(d);
    else d = this.WrapAngle_Directed(d, dir);
    d *= t;
    return p + d;
  },
};
