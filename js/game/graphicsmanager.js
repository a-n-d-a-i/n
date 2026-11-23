/* Literal port of audiovisual/GraphicsManager.as */
import { Sprite, MovieClip, AudioSystem } from "../flash.js";
import { asset_gfx_tiles } from "../assets.js";
import { ParticleManager_Classic, ParticleManager_Null } from "./particles.js";

export class GraphicsManager {
  constructor(parent, entities, players, tileIDs, numRows, numCols, particles) {
    this.num_rows = numRows;
    this.num_cols = numCols;
    this.root = new Sprite();
    parent.addChild(this.root);
    this.entity_gfxList = [];
    this.player_gfxList = [];
    this.tile_mcList = new Array(numRows * numCols);
    const children = [];
    if (particles) {
      this.particle_buffer_back = new Sprite();
      children.push(this.particle_buffer_back);
    }
    for (const e of entities) {
      const g = e.GenerateGraphicComponent();
      if (g !== null) { g.RegisterGraphics(children); this.entity_gfxList.push(g); }
    }
    const playerChildren = [];
    for (const p of players) {
      const g = p.GenerateGraphicComponent();
      if (g !== null) { g.RegisterGraphics(playerChildren); this.player_gfxList.push(g); }
    }
    for (let i = playerChildren.length - 1; i >= 0; i--) children.push(playerChildren[i]);
    if (particles) {
      this.particle_buffer_front = new Sprite();
      children.push(this.particle_buffer_front);
    }
    for (let c = 0; c < this.num_cols; c++) {
      for (let r = 0; r < this.num_rows; r++) {
        const mc = new asset_gfx_tiles();
        mc.x = c * 24 + 12;
        mc.y = r * 24 + 12;
        const idx = c + r * this.num_cols;
        mc.gotoAndStop(tileIDs[idx] + 1);
        mc.cacheAsBitmap = true;
        this.tile_mcList[idx] = mc;
        children.push(mc);
      }
    }
    for (const c of children) this.root.addChild(c);
    this.pman = particles ? new ParticleManager_Classic(this.particle_buffer_back, this.particle_buffer_front)
                          : new ParticleManager_Null();
  }
  Hide() { this.root.visible = false; }
  Show() { this.root.visible = true; }
  Clear() {
    if (this.root.parent !== null) this.root.parent.removeChild(this.root);
    for (const g of this.entity_gfxList) if (g.dispose) g.dispose();
    for (const g of this.player_gfxList) if (g.dispose) g.dispose();
    for (const c of this.root.children.slice()) c.dispose && c.dispose();
    AudioSystem.stopAll();
  }
  GetParticleManager() { return this.pman; }
  Render() {
    for (const g of this.entity_gfxList) g.UpdateState();
    for (const g of this.player_gfxList) g.UpdateState();
  }
}
