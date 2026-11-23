/* Literal port of audiovisual/SoundManager.as */
import { AudioSystem, SoundTransform } from "../flash.js";
import { clip } from "../assets.js";

const asset_sfx_ragdollMC = clip("asset_sfx_ragdollMC");

export class SoundManager {
  constructor() {
    this.mc_ragdoll = new asset_sfx_ragdollMC();
    this.mc_ragdoll._alwaysTick = true;
    this.gold_snd_id = 524;
    this.gold_channels = [null, null];
    this.gold_oldest = 0;
    this.gold_triggered = false;
  }
  Tick() { this.gold_triggered = false; }
  PlaySound_Gold() {
    if (this.gold_triggered) return;
    this.gold_triggered = true;
    if (this.gold_channels[this.gold_oldest]) this.gold_channels[this.gold_oldest].stop();
    this.gold_channels[this.gold_oldest] = AudioSystem.play(this.gold_snd_id, 0.25);
    this.gold_oldest = (this.gold_oldest + 1) % 2;
  }
  PlaySound_Ragdoll(label) { this.mc_ragdoll.gotoAndPlay(label); }
  dispose() { if (this.mc_ragdoll) this.mc_ragdoll.dispose(); }
}
