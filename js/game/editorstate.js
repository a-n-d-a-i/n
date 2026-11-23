/* Literal port of editor/edat.as and editor/Editor_State.as (loading path). */
import { vec2 } from "./math.js";

export const edat = {
  num_cols: 31, num_rows: 23, cell_size: 24,
  quantize_steps_per_cell: 4, quantize_step_size: 6,
  ETYPE_PLAYER: 0, ETYPE_MINE: 1, ETYPE_GOLD: 2, ETYPE_DOOR_REGULAR: 3,
  ETYPE_DOOR_LOCKED: 4, ETYPE_SWITCH_LOCKED: 5, ETYPE_DOOR_TRAP: 6,
  ETYPE_SWITCH_TRAP: 7, ETYPE_ONEWAY: 8, ETYPE_EXIT_DOOR: 9, ETYPE_EXIT_SWITCH: 10,
  ETYPE_CHAINGUN: 11, ETYPE_LASER: 12, ETYPE_ZAP: 13, ETYPE_CHASER: 14,
  ETYPE_FLOORGUARD: 15, ETYPE_LAUNCHPAD: 16, ETYPE_BOUNCEBLOCK: 17,
  ETYPE_ROCKET: 18, ETYPE_TURRET: 19, ETYPE_THWOMP: 20, num_etypes: 21,
  ETYPE_NULLFLAG: 999,
  EPROP_TYPE: 0, EPROP_X: 1, EPROP_Y: 2, EPROP_DIR: 3, EPROP_MOVE: 4,
  DIR_R: 0, DIR_RD: 1, DIR_D: 2, DIR_LD: 3, DIR_L: 4, DIR_LU: 5, DIR_U: 6, DIR_RU: 7,
  MOVE_SURFACE_CW: 0, MOVE_SURFACE_CCW: 1, MOVE_WANDER_CW: 2, MOVE_WANDER_CCW: 3,
  STRUCTTYPE_PLAYER: 0, STRUCTTYPE_MINE: 1, STRUCTTYPE_GOLD: 2, STRUCTTYPE_EXIT: 3,
  STRUCTTYPE_DOOR_REGULAR: 4, STRUCTTYPE_DOOR_LOCKED: 5, STRUCTTYPE_DOOR_TRAP: 6,
  STRUCTTYPE_LAUNCHPAD: 7, STRUCTTYPE_ONEWAY: 8, STRUCTTYPE_CHAINGUN: 9,
  STRUCTTYPE_LASER: 10, STRUCTTYPE_ZAP: 11, STRUCTTYPE_CHASER: 12,
  STRUCTTYPE_FLOORGUARD: 13, STRUCTTYPE_BOUNCEBLOCK: 14, STRUCTTYPE_ROCKET: 15,
  STRUCTTYPE_TURRET: 16, STRUCTTYPE_THWOMP: 17, num_structtypes: 18,
  STRUCT_SIZE: [2, 2, 2, 4, 3, 5, 5, 3, 3, 4, 4, 4, 4, 2, 2, 2, 2, 3],
  MAP_STRUCT_TO_ETYPE: [0, 1, 2, 9, 3, 4, 6, 16, 8, 11, 12, 13, 14, 15, 17, 18, 19, 20],
  _dirvec: [
    new vec2(1, 0), new vec2(1 / Math.SQRT2, 1 / Math.SQRT2), new vec2(0, 1),
    new vec2(-1 / Math.SQRT2, 1 / Math.SQRT2), new vec2(-1, 0),
    new vec2(-1 / Math.SQRT2, -1 / Math.SQRT2), new vec2(0, -1),
    new vec2(1 / Math.SQRT2, -1 / Math.SQRT2),
  ],
  MAP_DIR_TO_VEC(dir) { return this._dirvec[dir].Clone(); },
};

export class Editor_State {
  constructor() {
    this.tileIDs = new Array(edat.num_cols * edat.num_rows).fill(0);
    this.entities = [];
  }
  static Load_From_Bytes(ba) {
    const st = new Editor_State();
    ba.position = 0;
    ba.readUnsignedByte(); ba.readUnsignedByte(); ba.readUnsignedByte(); ba.readUnsignedByte();
    if (ba.bytesAvailable < st.tileIDs.length) return new Editor_State();
    for (let i = 0; i < st.tileIDs.length; i++) st.tileIDs[i] = ba.readUnsignedByte();
    for (let s = 0; s < edat.num_structtypes; s++) {
      if (ba.bytesAvailable < 2) return new Editor_State();
      const count = ba.readShort();
      const start = ba.position;
      for (let i = 0; i < count; i++) {
        const e = [edat.MAP_STRUCT_TO_ETYPE[s]];
        st.entities.push(e);
        if (s === edat.STRUCTTYPE_EXIT) {
          const sw = [edat.ETYPE_EXIT_SWITCH];
          st.entities.push(sw);
          if (ba.bytesAvailable < 4) return new Editor_State();
          e.push(ba.readUnsignedByte()); e.push(ba.readUnsignedByte());
          sw.push(ba.readUnsignedByte()); sw.push(ba.readUnsignedByte());
        } else if (s === edat.STRUCTTYPE_DOOR_LOCKED || s === edat.STRUCTTYPE_DOOR_TRAP) {
          const sw = [s === edat.STRUCTTYPE_DOOR_LOCKED ? edat.ETYPE_SWITCH_LOCKED : edat.ETYPE_SWITCH_TRAP];
          st.entities.push(sw);
          if (ba.bytesAvailable < 5) return new Editor_State();
          e.push(ba.readUnsignedByte()); e.push(ba.readUnsignedByte()); e.push(ba.readUnsignedByte());
          sw.push(ba.readUnsignedByte()); sw.push(ba.readUnsignedByte());
        } else {
          if (ba.bytesAvailable < edat.STRUCT_SIZE[s]) return new Editor_State();
          for (let k = 0; k < edat.STRUCT_SIZE[s]; k++) e.push(ba.readUnsignedByte());
        }
      }
    }
    return st;
  }
}
