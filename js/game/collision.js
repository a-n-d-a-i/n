/* Literal port of simulation/collision/*.as */
import { vec2 } from "./math.js";

export class AABB {
  constructor(x0, y0, x1, y1) { this.min = new vec2(x0, y0); this.max = new vec2(x1, y1); }
}

const zero_vec = new vec2(0, 0);

export class Segment_Linear {
  constructor(x0, y0, x1, y1) {
    this.p0 = new vec2(x0, y0);
    this.p1 = new vec2(x1, y1);
    this.aabb = new AABB(Math.min(this.p0.x, this.p1.x), Math.min(this.p0.y, this.p1.y),
                         Math.max(this.p0.x, this.p1.x), Math.max(this.p0.y, this.p1.y));
  }
  GetAABB() { return this.aabb; }
  GetClosestPoint(p, out) {
    const dx = this.p1.x - this.p0.x, dy = this.p1.y - this.p0.y;
    const px = p.x - this.p0.x, py = p.y - this.p0.y;
    const t = dx * px + dy * py;
    const l2 = dx * dx + dy * dy;
    if (t <= 0) out.Copy(this.p0);
    else if (t >= l2) out.Copy(this.p1);
    else {
      const s = t / l2;
      out.x = this.p0.x + s * dx; out.y = this.p0.y + s * dy;
    }
  }
  GetClosestPoint_IsBackfacing(p, out) {
    const dx = this.p1.x - this.p0.x, dy = this.p1.y - this.p0.y;
    const px = p.x - this.p0.x, py = p.y - this.p0.y;
    const t = dx * px + dy * py;
    const l2 = dx * dx + dy * dy;
    if (t <= 0) out.Copy(this.p0);
    else if (t >= l2) out.Copy(this.p1);
    else {
      const s = t / l2;
      out.x = this.p0.x + s * dx; out.y = this.p0.y + s * dy;
    }
    return px * -dy + py * dx < 0;
  }
  IntersectWithRay(origin, ray, radius, outP, outN) {
    const t0 = colutils.TimeOfIntersection_Circle_vs_Circle(origin, ray, this.p0, zero_vec, radius);
    const t1 = colutils.TimeOfIntersection_Circle_vs_Circle(origin, ray, this.p1, zero_vec, radius);
    const t2 = colutils.TimeOfIntersection_Point_vs_Lineseg(origin, ray, this.p0, this.p1, radius);
    const t = Math.min(t0, t1, t2);
    if (t <= 1 && t >= 0) {
      ray_point.x = origin.x + t * ray.x;
      ray_point.y = origin.y + t * ray.y;
      if (radius > 0) {
        cp.x = 0; cp.y = 0;
        this.GetClosestPoint(ray_point, cp);
        let dx = ray_point.x - cp.x, dy = ray_point.y - cp.y;
        const l = Math.sqrt(dx * dx + dy * dy);
        dx /= l; dy /= l;
        outP.x = cp.x; outP.y = cp.y;
        outN.x = dx; outN.y = dy;
      } else {
        let dx = -(this.p1.y - this.p0.y), dy = this.p1.x - this.p0.x;
        const l = Math.sqrt(dx * dx + dy * dy);
        dx /= l; dy /= l;
        if (dx * ray.x + dy * ray.y > 0) { dx *= -1; dy *= -1; }
        outP.Copy(ray_point);
        outN.x = dx; outN.y = dy;
      }
    }
    return t;
  }
  DebugDraw() {}
  DebugDraw_Simple() {}
  DebugDraw_NoStyle() {}
}
const cp = new vec2();
const ray_point = new vec2();

export class Segment_Linear_DoubleSided extends Segment_Linear {
  GetClosestPoint_IsBackfacing(p, out) {
    super.GetClosestPoint_IsBackfacing(p, out);
    return false;
  }
}

export class Segment_Circular {
  constructor(cx, cy, x0, y0, x1, y1) {
    this.p0 = new vec2(x0, y0);
    this.p1 = new vec2(x1, y1);
    this.pC = new vec2(cx, cy);
    this.aabb = new AABB(Math.min(this.p0.x, this.p1.x), Math.min(this.p0.y, this.p1.y),
                         Math.max(this.p0.x, this.p1.x), Math.max(this.p0.y, this.p1.y));
  }
  GetAABB() { return this.aabb; }
  GetClosestPoint(p, out) {
    const ax = this.p0.x - this.pC.x, ay = this.p0.y - this.pC.y;
    const bx = this.p1.x - this.pC.x, by = this.p1.y - this.pC.y;
    let px = p.x - this.pC.x, py = p.y - this.pC.y;
    const c1 = px * -ay + py * ax;
    const c2 = px * -by + py * bx;
    const sx = this.p1.x - this.p0.x, sy = this.p1.y - this.p0.y;
    const d1 = sx * -ay + sy * ax;
    const d2 = sx * -by + sy * bx;
    const c1d1 = c1 * d1 <= 0;
    const c2d2 = c2 * d2 >= 0;
    if (c1d1) {
      if (c2d2) {
        if (px * sx + py * sy <= 0) out.Copy(this.p0); else out.Copy(this.p1);
      } else out.Copy(this.p0);
    } else if (c2d2) out.Copy(this.p1);
    else {
      const r = Math.sqrt(ax * ax + ay * ay);
      const l = Math.sqrt(px * px + py * py);
      px /= l; py /= l; px *= r; py *= r;
      out.x = this.pC.x + px; out.y = this.pC.y + py;
    }
  }
  GetClosestPoint_IsBackfacing(p, out) {
    const ax = this.p0.x - this.pC.x, ay = this.p0.y - this.pC.y;
    const bx = this.p1.x - this.pC.x, by = this.p1.y - this.pC.y;
    let px = p.x - this.pC.x, py = p.y - this.pC.y;
    const c1 = px * -ay + py * ax;
    const c2 = px * -by + py * bx;
    const sx = this.p1.x - this.p0.x, sy = this.p1.y - this.p0.y;
    const d1 = sx * -ay + sy * ax;
    const d2 = sx * -by + sy * bx;
    const c1d1 = c1 * d1 <= 0;
    const c2d2 = c2 * d2 >= 0;
    let corner = -1;
    if (c1d1) {
      if (c2d2) {
        if (px * sx + py * sy <= 0) { out.Copy(this.p0); corner = 0; }
        else { out.Copy(this.p1); corner = 1; }
      } else { out.Copy(this.p0); corner = 0; }
    } else if (c2d2) { out.Copy(this.p1); corner = 1; }
    else {
      const r = Math.sqrt(ax * ax + ay * ay);
      const l = Math.sqrt(px * px + py * py);
      px /= l; py /= l; px *= r; py *= r;
      out.x = this.pC.x + px; out.y = this.pC.y + py;
    }
    const dx = out.x - p.x, dy = out.y - p.y;
    if (corner < 0) return dx * -sy + dy * sx > 0;
    let rx = ax, ry = ay;
    if (corner === 1) { rx = bx; ry = by; }
    if (rx * -sy + ry * sx < 0) { rx *= -1; ry *= -1; }
    return dx * rx + dy * ry > 0;
  }
  IntersectWithRay(origin, ray, radius, outP, outN) {
    const t0 = colutils.TimeOfIntersection_Circle_vs_Circle(origin, ray, this.p0, zero_vec, radius);
    const t1 = colutils.TimeOfIntersection_Circle_vs_Circle(origin, ray, this.p1, zero_vec, radius);
    let t2 = 2;
    this.GetClosestPoint(origin, cp);
    const dx = origin.x - cp.x, dy = origin.y - cp.y;
    const d = Math.sqrt(dx * dx + dy * dy);
    if (d <= radius) t2 = -1;
    else t2 = colutils.TimeOfIntersection_Circle_vs_Arc(origin, ray, this.pC, this.p0, this.p1, radius);
    const t = Math.min(t0, t1, t2);
    if (t <= 1 && t >= 0) {
      ray_point.x = origin.x + t * ray.x;
      ray_point.y = origin.y + t * ray.y;
      if (radius > 0) {
        this.GetClosestPoint(ray_point, cp);
        let ex = ray_point.x - cp.x, ey = ray_point.y - cp.y;
        const l = Math.sqrt(ex * ex + ey * ey);
        ex /= l; ey /= l;
        outP.x = cp.x; outP.y = cp.y;
        outN.x = ex; outN.y = ey;
      } else {
        let ex = ray_point.x - this.pC.x, ey = ray_point.y - this.pC.y;
        const l = Math.sqrt(ex * ex + ey * ey);
        ex /= l; ey /= l;
        if (ex * ray.x + ey * ray.y > 0) { ex *= -1; ey *= -1; }
        outP.Copy(ray_point);
        outN.x = ex; outN.y = ey;
      }
    }
    return t;
  }
  DebugDraw() {}
  DebugDraw_Simple() {}
  DebugDraw_NoStyle() {}
}

export class Grid_Base {
  constructor(cols, rows, cell) {
    this.numcols = cols; this.numrows = rows; this.cellsize = cell;
    this.numcells = cols * rows;
  }
  WorldspaceToGridspace(v) { return Math.floor(v / this.cellsize); }
  GetCellIndexFromWorldspacePosition(x, y) {
    return this.GetCellIndexFromGridspacePosition(this.WorldspaceToGridspace(x), this.WorldspaceToGridspace(y));
  }
  GetCellIndexFromGridspacePosition(c, r) {
    if (c < 0 || c >= this.numcols || r < 0 || r >= this.numrows) {
      c = Math.max(0, Math.min(this.numcols - 1, c));
      r = Math.max(0, Math.min(this.numrows - 1, r));
    }
    return r * this.numcols + c;
  }
  DEBUG_GetWorldspaceCellCenterPositionFromIndex(i) {
    if (i === -1) return null;
    const c = i % this.numcols, r = Math.floor(i / this.numcols);
    return new vec2((c + 0.5) * this.cellsize, (r + 0.5) * this.cellsize);
  }
}

export class Grid_Segment extends Grid_Base {
  constructor(cols, rows, cell) {
    super(cols, rows, cell);
    this.cells = new Array(this.numcells);
    for (let i = 0; i < this.numcells; i++) this.cells[i] = [];
    this.TEMP_ray_pos = new vec2();
    this.TEMP_ray_vec = new vec2();
    this.TEMP_temp_p = new vec2();
    this.TEMP_temp_n = new vec2();
  }
  Debug_Draw() {}
  GetRaycastDistance(x, y, rx, ry, outP, outN) {
    let cx = this.WorldspaceToGridspace(x);
    let cy = this.WorldspaceToGridspace(y);
    let sx = 0, sy = 0;
    let tx = 999999, ty = 999999;
    let dx = 0, dy = 0;
    if (rx < 0) { sx = -1; tx = (cx * this.cellsize - x) / rx; dx = this.cellsize / -rx; }
    else if (rx > 0) { sx = 1; tx = ((cx + 1) * this.cellsize - x) / rx; dx = this.cellsize / rx; }
    if (ry < 0) { sy = -1; ty = (cy * this.cellsize - y) / ry; dy = this.cellsize / -ry; }
    else if (ry > 0) { sy = 1; ty = ((cy + 1) * this.cellsize - y) / ry; dy = this.cellsize / ry; }
    if (sx === 0 && sy === 0) return -1;
    const far = 2000;
    this.TEMP_ray_pos.x = x; this.TEMP_ray_pos.y = y;
    this.TEMP_ray_vec.x = far * rx; this.TEMP_ray_vec.y = far * ry;
    let t = 2;
    while (true) {
      const hit = this.IntersectRayVsCellContents(cx, cy, this.TEMP_ray_pos, this.TEMP_ray_vec, outP, outN);
      if (hit === -1) break;
      if (hit !== 2) return hit * far;
      if (tx < ty) {
        tx += dx; cx += sx;
        if (cx < 0 || cx >= this.numcols) return -1;
      } else {
        ty += dy; cy += sy;
        if (cy < 0 || cy >= this.numrows) return -1;
      }
    }
    return -1;
  }
  RaycastVsPlayer(p0, p1, radius, outP, outN) {
    let dx = p1.x - p0.x, dy = p1.y - p0.y;
    let len = Math.sqrt(dx * dx + dy * dy);
    if (len < radius) return true;
    dx /= len; dy /= len;
    len -= radius;
    const hit = this.GetRaycastDistance(p0.x, p0.y, dx, dy, outP, outN);
    if (len < hit) return true;
    if (hit === -1) {
      outP.x = 0; outP.y = 0; outN.x = 1; outN.y = 0;
    }
    return false;
  }
  IntersectRayVsCellContents(cx, cy, pos, ray, outP, outN) {
    let best = 2;
    this.TEMP_temp_p.x = 0; this.TEMP_temp_p.y = 0;
    this.TEMP_temp_n.x = 0; this.TEMP_temp_n.y = 0;
    const idx = this.GetCellIndexFromGridspacePosition(cx, cy);
    const arr = this.cells[idx];
    for (let i = 0; i < arr.length; i++) {
      const t = arr[i].IntersectWithRay(pos, ray, 0, this.TEMP_temp_p, this.TEMP_temp_n);
      if (t === -1) return -1;
      if (t < best) {
        best = t;
        outP.Copy(this.TEMP_temp_p);
        outN.Copy(this.TEMP_temp_n);
      }
    }
    return best;
  }
  DEBUG_GetCellContentsFromGridspacePosition(c, r) {
    return this.cells[this.GetCellIndexFromGridspacePosition(c, r)];
  }
  Clear() { for (const c of this.cells) c.length = 0; }
  AddSegToCell(c, r, seg) {
    const idx = this.GetCellIndexFromGridspacePosition(c, r);
    this.cells[idx].push(seg);
  }
  DOOR_AddSegment(idx, seg) {
    const a = this.cells[idx];
    if (a.indexOf(seg) !== -1) return;
    a.push(seg);
  }
  DOOR_RemoveSegment(idx, seg) {
    const a = this.cells[idx];
    const i = a.indexOf(seg);
    if (i !== -1) a.splice(i, 1);
  }
  DOOR_GetCellIndexFromGridspacePosition(c, r) { return this.GetCellIndexFromGridspacePosition(c, r); }
  GatherCellContentsFromWorldspaceRegion(x0, y0, x1, y1, out) {
    const c0 = this.WorldspaceToGridspace(x0), c1 = this.WorldspaceToGridspace(x1);
    const r0 = this.WorldspaceToGridspace(y0), r1 = this.WorldspaceToGridspace(y1);
    out.length = 0;
    for (let r = r0; r <= r1; r++) {
      for (let c = c0; c <= c1; c++) {
        const idx = this.GetCellIndexFromGridspacePosition(c, r);
        const arr = this.cells[idx];
        for (let i = 0; i < arr.length; i++) out.push(arr[i]);
      }
    }
  }
}

export class Grid_Entity extends Grid_Base {
  constructor(cols, rows, cell) {
    super(cols, rows, cell);
    this.cells = new Array(this.numcells);
    for (let i = 0; i < this.numcells; i++) this.cells[i] = [];
  }
  Debug_Draw() {}
  Clear() { for (const c of this.cells) c.length = 0; }
  ENTITY_Move(pos, ent) {
    const old = ent.GRID_GetGridIndex();
    const idx = this.GetCellIndexFromWorldspacePosition(pos.x, pos.y);
    if (old === idx) return;
    if (old === -1) return;
    this._remove(old, ent);
    this.cells[idx].push(ent);
    ent.GRID_SetGridIndex(idx);
  }
  ENTITY_Remove(ent) {
    const idx = ent.GRID_GetGridIndex();
    if (idx === -1) return;
    this._remove(idx, ent);
    ent.GRID_SetGridIndex(-1);
  }
  ENTITY_Add(pos, ent) {
    if (ent.GRID_GetGridIndex() !== -1) return;
    const idx = this.GetCellIndexFromWorldspacePosition(pos.x, pos.y);
    this.cells[idx].push(ent);
    ent.GRID_SetGridIndex(idx);
  }
  _remove(idx, ent) {
    const a = this.cells[idx];
    const i = a.indexOf(ent);
    if (i !== -1) a.splice(i, 1);
  }
  GatherCellContentsInNeighbourhood(pos, out) {
    out.length = 0;
    const c = this.WorldspaceToGridspace(pos.x);
    const r = this.WorldspaceToGridspace(pos.y);
    // AS3 iterates columns in the outer loop and rows in the inner loop.
    for (let dx = -1; dx < 2; dx++) {
      for (let dy = -1; dy < 2; dy++) {
        const idx = this.GetCellIndexFromGridspacePosition(c + dx, r + dy);
        const arr = this.cells[idx];
        for (let i = 0; i < arr.length; i++) out.push(arr[i]);
      }
    }
  }
}

export class Grid_Edges extends Grid_Base {
  constructor(cols, rows, cell) {
    super(cols, rows, cell);
    this.edges_tileX = new Array(this.numcells).fill(0);
    this.edges_tileY = new Array(this.numcells).fill(0);
    this.edges_doorX = new Array(this.numcells).fill(0);
    this.edges_doorY = new Array(this.numcells).fill(0);
  }
  Clear() {
    for (let i = 0; i < this.numcells; i++) {
      this.edges_tileX[i] = 0; this.edges_tileY[i] = 0;
      this.edges_doorX[i] = 0; this.edges_doorY[i] = 0;
    }
  }
  Debug_Draw() {}
  DOOR_GetCellIndexFromGridspacePosition(c, r) { return this.GetCellIndexFromGridspacePosition(c, r); }
  GetGridCoordinateFromWorldspace_1D(v) { return this.WorldspaceToGridspace(v); }
  GetWorldspaceCoordinateFromGridEdge_1D(coord, dir) {
    return (coord + Math.max(0, dir)) * this.cellsize;
  }
  IsSolid(c, r, dir, axis) {
    const idx = this._idx(c, r, dir, axis);
    if (axis === 0) return this.edges_tileX[idx] === 2 || this.edges_doorX[idx] !== 0;
    return this.edges_tileY[idx] === 2 || this.edges_doorY[idx] !== 0;
  }
  IsSolid_IgnoreDoors(c, r, dir, axis) {
    const idx = this._idx(c, r, dir, axis);
    if (axis === 0) return this.edges_tileX[idx] === 2;
    return this.edges_tileY[idx] === 2;
  }
  IsEmpty(c, r, dir, axis) {
    const idx = this._idx(c, r, dir, axis);
    if (axis === 0) return this.edges_tileX[idx] === 0 && this.edges_doorX[idx] === 0;
    return this.edges_tileY[idx] === 0 && this.edges_doorY[idx] === 0;
  }
  ScanHorizontal(row, row2, from, to) {
    const d = to - from;
    if (d === 0) return true;
    return this.ScanHorizontal_Directed(row, row2, from, to, d / Math.abs(d));
  }
  ScanHorizontal_Directed(row, row2, from, to, dir) {
    let c = from;
    while (c !== to) {
      if (!this.IsEmpty_Column(c, row, row2, dir)) return false;
      c += dir;
      if (Math.abs(c) > 100) return false;
    }
    return true;
  }
  ScanVertical(col, col2, from, to) {
    const d = to - from;
    if (d === 0) return true;
    return this.ScanVertical_Directed(col, col2, from, to, d / Math.abs(d));
  }
  ScanVertical_Directed(col, col2, from, to, dir) {
    let r = from;
    while (r !== to) {
      if (!this.IsEmpty_Row(r, col, col2, dir)) return false;
      r += dir;
      if (Math.abs(r) > 100) return false;
    }
    return true;
  }
  SweepHorizontal(row, row2, from, dir) {
    let c = from;
    while (this.IsEmpty_Column(c, row, row2, dir)) {
      c += dir;
      if (Math.abs(c) > 100) return from;
    }
    return c;
  }
  SweepVertical(col, col2, from, dir) {
    let r = from;
    while (this.IsEmpty_Row(r, col, col2, dir)) {
      r += dir;
      if (Math.abs(r) > 100) return from;
    }
    return r;
  }
  IsEmpty_Column(col, r0, r1, dir) {
    for (let r = r0; r <= r1; r++) if (!this.IsEmpty(col, r, dir, 0)) return false;
    return true;
  }
  IsEmpty_Row(row, c0, c1, dir) {
    for (let c = c0; c <= c1; c++) if (!this.IsEmpty(c, row, 0, dir)) return false;
    return true;
  }
  GAME_LoadTileEdges(c, r, type) {
    // literal port of Grid_Edges.GAME_LoadTileEdges
    const c2 = c * 2, r2 = r * 2;
    for (let i = 0; i < 3; i++) {
      for (let j = 0; j < 2; j++) {
        const ec = c2 - 1 + i, er = r2 + j;
        const ec2 = c2 + j, er2 = r2 - 1 + i;
        const idx1 = this.GetCellIndexFromGridspacePosition(ec, er);
        const idx2 = this.GetCellIndexFromGridspacePosition(ec2, er2);
        const k = i + j * 3;
        this._loadX(idx1, EDGE_STATES_X[type * 6 + k]);
        this._loadY(idx2, EDGE_STATES_Y[type * 6 + k]);
      }
    }
  }
  DOOR_IncrementEdge(idx, horizontal) {
    if (horizontal) this.edges_doorX[idx] += 1; else this.edges_doorY[idx] += 1;
  }
  DOOR_DecrementEdge(idx, horizontal) {
    if (horizontal) { if (this.edges_doorX[idx] > 0) this.edges_doorX[idx] -= 1; }
    else { if (this.edges_doorY[idx] > 0) this.edges_doorY[idx] -= 1; }
  }
  _idx(c, r, dir, axis) {
    // Literal port of Grid_Edges.GetIndexFromGridspaceAndOffset:
    // X edges use (dir, 0); Y edges are queried as (0, dir), i.e. the
    // direction lives in the axis argument.
    if (axis === 0) {
      if (dir === -1) return this.GetCellIndexFromGridspacePosition(c - 1, r);
      if (dir === 1) return this.GetCellIndexFromGridspacePosition(c, r);
    } else if (dir === 0) {
      if (axis === -1) return this.GetCellIndexFromGridspacePosition(c, r - 1);
      if (axis === 1) return this.GetCellIndexFromGridspacePosition(c, r);
    }
    return -1;
  }
  _loadX(idx, v) {
    if (this.edges_tileX[idx] === 2 && v === 2) this.edges_tileX[idx] = 0;
    else this.edges_tileX[idx] = Math.max(this.edges_tileX[idx], v);
  }
  _loadY(idx, v) {
    if (this.edges_tileY[idx] === 2 && v === 2) this.edges_tileY[idx] = 0;
    else this.edges_tileY[idx] = Math.max(this.edges_tileY[idx], v);
  }
}

// edgedefs tables (needed by Grid_Edges.GAME_LoadTileEdges)
// populated by tiles.js via initEdgeStates, but kept here to avoid a cycle
const EDGE_STATES_X = new Array(42 * 6).fill(0);
const EDGE_STATES_Y = new Array(42 * 6).fill(0);
export function setEdgeStateX(type, a, b, c, d, e, f) {
  const o = type * 6;
  EDGE_STATES_X[o] = a; EDGE_STATES_X[o + 1] = b; EDGE_STATES_X[o + 2] = c;
  EDGE_STATES_X[o + 3] = d; EDGE_STATES_X[o + 4] = e; EDGE_STATES_X[o + 5] = f;
}
export function setEdgeStateY(type, a, b, c, d, e, f) {
  const o = type * 6;
  EDGE_STATES_Y[o] = a; EDGE_STATES_Y[o + 1] = b; EDGE_STATES_Y[o + 2] = c;
  EDGE_STATES_Y[o + 3] = d; EDGE_STATES_Y[o + 4] = e; EDGE_STATES_Y[o + 5] = f;
}
export function edgeStateX(type, k) { return EDGE_STATES_X[type * 6 + k]; }
export function edgeStateY(type, k) { return EDGE_STATES_Y[type * 6 + k]; }
export function copyEdgeStates(src, dst) {
  for (let k = 0; k < 6; k++) { EDGE_STATES_X[dst * 6 + k] = EDGE_STATES_X[src * 6 + k]; EDGE_STATES_Y[dst * 6 + k] = EDGE_STATES_Y[src * 6 + k]; }
}
export function rotateEdgeStates90(src, dst) {
  const sx = src * 6, dx = dst * 6;
  EDGE_STATES_Y[dx + 0] = EDGE_STATES_X[sx + 3]; EDGE_STATES_Y[dx + 1] = EDGE_STATES_X[sx + 4]; EDGE_STATES_Y[dx + 2] = EDGE_STATES_X[sx + 5];
  EDGE_STATES_Y[dx + 3] = EDGE_STATES_X[sx + 0]; EDGE_STATES_Y[dx + 4] = EDGE_STATES_X[sx + 1]; EDGE_STATES_Y[dx + 5] = EDGE_STATES_X[sx + 2];
  EDGE_STATES_X[dx + 0] = EDGE_STATES_Y[sx + 2]; EDGE_STATES_X[dx + 1] = EDGE_STATES_Y[sx + 1]; EDGE_STATES_X[dx + 2] = EDGE_STATES_Y[sx + 0];
  EDGE_STATES_X[dx + 3] = EDGE_STATES_Y[sx + 5]; EDGE_STATES_X[dx + 4] = EDGE_STATES_Y[sx + 4]; EDGE_STATES_X[dx + 5] = EDGE_STATES_Y[sx + 3];
}
export function rotateEdgeStates180(src, dst) {
  const sx = src * 6, dx = dst * 6;
  for (let k = 0; k < 6; k++) {
    EDGE_STATES_X[dx + k] = EDGE_STATES_X[sx + 5 - k];
    EDGE_STATES_Y[dx + k] = EDGE_STATES_Y[sx + 5 - k];
  }
}
export function rotateEdgeStates270(src, dst) {
  const sx = src * 6, dx = dst * 6;
  EDGE_STATES_Y[dx + 0] = EDGE_STATES_X[sx + 2]; EDGE_STATES_Y[dx + 1] = EDGE_STATES_X[sx + 1]; EDGE_STATES_Y[dx + 2] = EDGE_STATES_X[sx + 0];
  EDGE_STATES_Y[dx + 3] = EDGE_STATES_X[sx + 5]; EDGE_STATES_Y[dx + 4] = EDGE_STATES_X[sx + 4]; EDGE_STATES_Y[dx + 5] = EDGE_STATES_X[sx + 3];
  EDGE_STATES_X[dx + 0] = EDGE_STATES_Y[sx + 3]; EDGE_STATES_X[dx + 1] = EDGE_STATES_Y[sx + 4]; EDGE_STATES_X[dx + 2] = EDGE_STATES_Y[sx + 5];
  EDGE_STATES_X[dx + 3] = EDGE_STATES_Y[sx + 0]; EDGE_STATES_X[dx + 4] = EDGE_STATES_Y[sx + 1]; EDGE_STATES_X[dx + 5] = EDGE_STATES_Y[sx + 2];
}

export const colutils = {
  cp: new vec2(),
  segList: [],
  GetSingleClosestPoint_Signed(grid, p, radius, out) {
    const cp = this.cp;
    let result = 0;
    let best = 99999999;
    grid.GatherCellContentsFromWorldspaceRegion(p.x - radius, p.y - radius, p.x + radius, p.y + radius, this.segList);
    for (let i = 0; i < this.segList.length; i++) {
      const back = this.segList[i].GetClosestPoint_IsBackfacing(p, cp);
      const dx = cp.x - p.x, dy = cp.y - p.y;
      let d = dx * dx + dy * dy;
      if (!back) d -= 0.1;
      if (d < best) {
        out.Copy(cp);
        best = d;
        result = back ? -1 : 1;
      }
    }
    return result;
  },
  Penetration_Square_vs_Point(sq, half, p, out) {
    const dx = p.x - sq.x, dy = p.y - sq.y;
    const py = half - Math.abs(dy);
    if (py > 0) {
      const px = half - Math.abs(dx);
      if (px > 0) {
        if (py <= px) {
          out.x = 0; out.y = dy <= 0 ? -1 : 1;
          return py;
        }
        out.y = 0; out.x = dx <= 0 ? -1 : 1;
        return px;
      }
    }
    return 0;
  },
  Overlap_Circle_Vs_Segment(p, r, a, b, len) {
    const dx = p.x - a.x, dy = p.y - a.y;
    const ux = (b.x - a.x) / len, uy = (b.y - a.y) / len;
    const t = dx * ux + dy * uy;
    if (t <= 0) this.cp.Copy(a);
    else if (t >= len) this.cp.Copy(b);
    else { this.cp.x = a.x + t * ux; this.cp.y = a.y + t * uy; }
    const ex = p.x - this.cp.x, ey = p.y - this.cp.y;
    return ex * ex + ey * ey < r * r;
  },
  Overlap_Circle_Vs_Circle(a, ar, b, br) {
    const dx = b.x - a.x, dy = b.y - a.y;
    const rr = ar + br;
    return dx * dx + dy * dy < rr * rr;
  },
  TimeOfIntersection_Circle_vs_Circle(a, va, b, vb, r) {
    const vx = va.x - vb.x, vy = va.y - vb.y;
    const dx = a.x - b.x, dy = a.y - b.y;
    const a2 = vx * vx + vy * vy;
    const b2 = 2 * (dx * vx + dy * vy);
    const c2 = dx * dx + dy * dy - r * r;
    if (c2 <= 0) return -1;
    if (Math.abs(a2) < 0.0001) return 2;
    if (b2 >= 0) return 2;
    const disc = b2 * b2 - 4 * a2 * c2;
    if (disc < 0) return 2;
    const q = -0.5 * (b2 - Math.sqrt(disc));
    const t1 = q / a2, t2 = c2 / q;
    return Math.min(t1, t2);
  },
  TimeOfIntersection_Point_vs_Lineseg(a, va, p0, p1, r) {
    let sx = p1.x - p0.x, sy = p1.y - p0.y;
    const len = Math.sqrt(sx * sx + sy * sy);
    sx /= len; sy /= len;
    const nx = -sy, ny = sx;
    const dx = a.x - p0.x, dy = a.y - p0.y;
    const dist = nx * dx + ny * dy;
    const vn = nx * va.x + ny * va.y;
    const along = sx * dx + sy * dy;
    const absd = Math.abs(dist);
    const gap = absd - r;
    if (gap < 0) {
      if (along < 0 || along > len) return 2;
      return -1;
    }
    if (dist * vn >= 0) return 2;
    const t = gap / Math.abs(vn);
    const vlen = sx * va.x + sy * va.y;
    const at = along + t * vlen;
    if (at < 0 || at > len) return 2;
    return t;
  },
  TimeOfIntersection_Circle_vs_Arc(a, va, c, p0, p1, r) {
    const dx = p0.x - c.x, dy = p0.y - c.y;
    const cr = Math.sqrt(dx * dx + dy * dy);
    const t1 = this._TOI_ArcHelper(a, va, c, p0, p1, cr + r);
    const t2 = this._TOI_ArcHelper(a, va, c, p0, p1, cr - r);
    return Math.min(t1, t2);
  },
  _TOI_ArcHelper(a, va, c, p0, p1, r) {
    const dx = a.x - c.x, dy = a.y - c.y;
    const A = va.Dot(va);
    const B = 2 * (dx * va.x + dy * va.y);
    const C = dx * dx + dy * dy - r * r;
    if (Math.abs(A) < 0.0001) return 2;
    const disc = B * B - 4 * A * C;
    if (disc < 0) return 2;
    const q = -0.5 * (B - Math.sqrt(disc));
    let t1 = q / A, t2 = C / q;
    const ax = p0.x - c.x, ay = p0.y - c.y;
    const bx = p1.x - c.x, by = p1.y - c.y;
    const ex = p1.x - p0.x, ey = p1.y - p0.y;
    const d1 = ex * -ay + ey * ax;
    const d2 = ex * -by + ey * bx;
    if (t1 < 0) t1 = 2;
    if (t2 < 0) t2 = 2;
    if (t1 <= 1) {
      const px = a.x + t1 * va.x - c.x, py = a.y + t1 * va.y - c.y;
      const e1 = px * -ay + py * ax;
      const e2 = px * -by + py * bx;
      if (e1 * d1 <= 0 || e2 * d2 >= 0) t1 = 2;
    }
    if (t2 <= 1) {
      const px = a.x + t2 * va.x - c.x, py = a.y + t2 * va.y - c.y;
      const e1 = px * -ay + py * ax;
      const e2 = px * -by + py * bx;
      if (e1 * d1 <= 0 || e2 * d2 >= 0) t2 = 2;
    }
    return Math.min(t1, t2);
  },
};
