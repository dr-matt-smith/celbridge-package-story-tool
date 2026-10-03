{
  "name": "Week 7 — Observer",
  "description": "COMP H3032 Design Patterns · Exercise 11 — reverse the arrows. Converted from weeks/slides-md/week07-observer.md.",
  "navigation": {
    "show": true,
    "style": "arrows-name",
    "position": "top-right",
    "showNumber": true
  },
  "sequenceArrows": {
    "show": true,
    "style": "dashed",
    "color": "#ffcc00",
    "alpha": 0.55
  },
  "nodes": [
    {
      "name": "Start",
      "x": 0,
      "y": 0,
      "text": "# Observer\n\n### Week 7 · Exercise 11 — the fourth pattern, and the first one about *wiring*\n\nCOMP H3032 — Design Patterns · the Player stops knowing everyone\n\n<!--\nSpeaker note: every pattern so far improved one object's internals. This one is about\nthe RELATIONSHIP between objects — an object that quietly became the hub everything is\nwired into. Lead with the count, not the bus.\n-->\n"
    },
    {
      "name": "Java example",
      "x": 60,
      "y": 40,
      "text": "see the image\n\n![some Jav](images/java.png)"
    },
    {
      "name": "The-Problem",
      "x": 240,
      "y": 0,
      "text": "# The problem: count the coupling\n\nRead `Player.takeDamage()` in the naive engine and list what it touches:\n\n```ts\ntakeDamage(amount) {\n  this.scene.flashAmount = 1;          // screen / UI\n  playSound('hurt');                   // audio\n  if (this.health <= 0) {\n    playSound('death');                // audio\n    this.scene.endGame();              // game-flow\n  }\n}\n```\n\nThe Player **imports the audio** and **holds a reference to the whole scene**. Every new reaction to damage — rumble, a combo counter, a kill-cam — is another line *here*.\n\n> That count of subsystems the Player names **is** the smell.\n\n<style scoped>section { font-size: 26px; }</style>\n"
    },
    {
      "name": "The-Move",
      "x": 480,
      "y": 0,
      "text": "# The move\n\n## The Player *announces*. It doesn't *dispatch*.\n\nIt emits `player:damaged` / `player:died` and stops.\nThe subsystems subscribe themselves.\n"
    },
    {
      "name": "The-Subject",
      "x": 720,
      "y": 0,
      "text": "# The Subject: a tiny typed event bus\n\n`src/game/events/event-bus.ts`\n\n```ts\nexport type Handler<T> = (payload: T) => void;\n\nexport class EventBus<Events extends Record<string, unknown>> {\n  // One list of handlers per event name.\n  private handlers: { [K in keyof Events]?: Handler<Events[K]>[] } = {};\n\n  /** Subscribe to an event. Returns an unsubscribe function. */\n  on<K extends keyof Events>(event: K, handler: Handler<Events[K]>): () => void {\n    (this.handlers[event] ??= []).push(handler);\n    return () => this.off(event, handler);\n  }\n\n  /** Announce an event. Every subscriber is called, in subscription order. */\n  emit<K extends keyof Events>(event: K, payload: Events[K]): void {\n    // Iterate a copy so a handler that unsubscribes mid-emit can't corrupt the walk.\n    for (const handler of [...(this.handlers[event] ?? [])]) handler(payload);\n  }\n\n  // … off() unsubscribes one handler; clear() drops them all on scene reset\n}\n```\n\n`on` registers a handler; `emit` calls everyone listening for that event. Neither the publisher nor the subscribers hold a reference to each other — only to the bus.\n\n<style scoped>section { font-size: 22px; } pre { font-size: 0.7em; margin: 0.3em 0; } p { margin: 0.4em 0; }</style>\n"
    },
    {
      "name": "Typed-Events",
      "x": 720,
      "y": 140,
      "text": "# The vocabulary: typed events\n\n`src/game/events/game-events.ts`\n\n```ts\n// NOTE: a `type` alias, not an `interface` — only a type alias satisfies the\n// `Record<string, unknown>` constraint the EventBus uses (interfaces have no implicit\n// index signature). A small TypeScript gotcha worth knowing.\nexport type GameEvents = {\n  /** The player was hit (and may or may not have survived). */\n  'player:damaged': { amount: number; health: number };\n  /** The player's health reached zero. */\n  'player:died': { health: number };\n};\n```\n\nA typed event map keeps publishers and subscribers honest — emit the wrong payload and it won't compile. (It's a **`type`, not an `interface`**: only a type alias satisfies the bus's `Record<string, unknown>` constraint — a genuine TypeScript gotcha.)\n\n<style scoped>pre { font-size: 0.75em; }</style>\n"
    },
    {
      "name": "One-Dependency",
      "x": 480,
      "y": 140,
      "text": "# The Player now depends on ONE thing\n\n`src/game/player.ts` — `takeDamage()`\n\n```ts\ntakeDamage(amount: number): void {\n  if (this.invuln > 0) return;\n  this.health -= amount;\n  this.invuln = 0.6;\n\n  // ✅ Just announce it. WHO reacts — flash, audio, scoring — is not our concern.\n  this.events.emit('player:damaged', { amount, health: this.health });\n\n  if (this.health <= 0) {\n    this.health = 0;\n    this.events.emit('player:died', { health: this.health });\n  }\n}\n```\n\nThe `import { playSound }` and the scene back-reference are **gone**. `takeDamage()` names no subsystem — it just says what happened. *Who* reacts is not its concern.\n\n<style scoped>section { font-size: 26px; } pre { font-size: 0.75em; }</style>\n"
    },
    {
      "name": "Subscribers",
      "x": 240,
      "y": 140,
      "text": "# The subsystems become subscribers\n\n`observers/screen-flash.ts`\n\n```ts\nexport class ScreenFlash {\n  private amount = 0;\n\n  /** Wire this effect to the bus. The Player has no idea we exist. */\n  subscribe(bus: EventBus<GameEvents>): void {\n    bus.on('player:damaged', () => {\n      this.amount = 1;\n    });\n  }\n\n  // … update(), render() and reset() fade and draw its own flash\n}\n```\n\n`observers/audio-observer.ts`\n\n```ts\nimport { playSound } from '../audio';\n\n/** Subscribe the audio subsystem to the events it should react to. */\nexport function subscribeAudio(bus: EventBus<GameEvents>): void {\n  bus.on('player:damaged', () => playSound('hurt'));\n  bus.on('player:died', () => playSound('death'));\n}\n```\n\nEach owns its reaction and **subscribes itself**. The Player never mentions either.\n\n<style scoped>section { font-size: 21px; } pre { font-size: 0.7em; margin: 0.25em 0; } p { margin: 0.25em 0; }</style>\n"
    },
    {
      "name": "The-Wiring",
      "x": 0,
      "y": 140,
      "text": "# The wiring lives in the scene\n\n`src/game/game-scene.ts` — `reset()`\n\n```ts\n// Observer wiring: subsystems subscribe to the bus; the Player only emits. Clearing\n// first stops handlers piling up across restarts. Adding a reaction to damage is a\n// new line HERE (or a new observer module) — never an edit to Player.takeDamage().\nthis.events.clear();\nthis.flash.subscribe(this.events); // screen flash  ← player:damaged\nsubscribeAudio(this.events); // hurt / death sounds\nthis.events.on('player:died', () => this.endGame()); // game-over flow\n```\n\nThe scene owns the bus and registers subscribers — even game-over is *just another listener*. `clear()` first so handlers don't pile up across restarts. Run it: **the game plays identically.** The behaviour didn't change — the coupling did.\n"
    },
    {
      "name": "Arrow-Reversed",
      "x": 0,
      "y": 280,
      "text": "# The arrow, reversed\n\n```text\nBEFORE — Player knows everyone      AFTER — everyone knows the bus\n\n          ┌──▶ screen flash         ScreenFlash ─────┐\nPlayer ───┼──▶ audio                audio ───────────┤\n          └──▶ game-over            game-over ───────┼──▶ ( EventBus )\n                                    Player ──emit────┘\n```\n\n**Before:** `Player ──▶` every subsystem. **After:** every subsystem `──▶ bus ◀──` Player. Nobody points at the Player.\n"
    },
    {
      "name": "Open-Closed",
      "x": 240,
      "y": 280,
      "text": "# Why it matters: open for extension\n\nAdd a brand-new reaction to damage **without opening `player.ts`**:\n\n```ts\n// anywhere with the bus — e.g. in the scene's reset()\nthis.events.on('player:damaged', e => console.log('combo!', e.health))\n```\n\nIt works, and the publisher never knew. New reactions are **new subscribers**, not edits to the thing that fires the event.\n\nThat's the **Open/Closed Principle**: open for extension, closed for modification.\n"
    },
    {
      "name": "Trade-Off",
      "x": 480,
      "y": 280,
      "text": "# The honest trade-off\n\n**Won:** the Player depends on nothing but the bus; reactions are open-ended and added without touching the publisher. Decoupled.\n\n**Paid:** the flow is now **indirect**. You can't read `takeDamage()` and see what happens next — you have to know who subscribed. Ordering matters, one handler's error can swallow the rest, and a forgotten unsubscribe leaks. For two subsystems a direct call is simpler; Observer earns its keep when the list of reactions is **open-ended**.\n\n> *Reflection:* `takeDamage()` used to name every subsystem it affected, so the Player was coupled to all of them and each new reaction edited that one method. Now it only emits to the bus and the subsystems subscribe themselves — the dependency arrow points from each subsystem into the bus instead of from the Player out to each subsystem.\n\n<style scoped>blockquote { font-size: 0.75em; }</style>\n"
    },
    {
      "name": "Next-Command",
      "x": 720,
      "y": 280,
      "text": "# Next: Command\n\nThe Player is decoupled now. But the scene still reads input **inline** — `isDown('Space')`, `isDown('KeyR')`, the hardcoded WASD block — and acts on it immediately.\n\n**Next week:** you can't rebind keys, replay inputs, or undo. Wrap each action in a **Command** object and bind keys to commands.\n\nCode from `code_projects/SOLUTIONS/week07_SOLUTION/`\n"
    },
    {
      "name": "Appendix-Score",
      "x": 720,
      "y": 420,
      "text": "# Appendix · stretch (optional) — carry the *score* through\n\nThe score is still a scene field the collision code mutates and the HUD reads. Route kills through `enemy:killed` → a stateful **Scoreboard**, then announce the ending — but **who** can? The Player **can't**: it doesn't know the score. **An event carries only what its publisher knows**, so the *scene* (which owns the Scoreboard) emits `game:over` with it:\n\n`game-scene.ts` — `endGame()` · the scene announces, carrying the score\n\n```ts\n/** Invoked by a `player:died` subscriber. The scene owns the score, so the scene is\n *  the one that can announce `game:over` — and it carries the final score in the\n *  payload, so the end screen is HANDED the number instead of reaching for it. */\nendGame(): void {\n  this.gameOver = true; // gameplay gate (stops the update loop below)\n  this.events.emit('game:over', { score: this.scoreboard.total });\n}\n```\n\n`observers/game-over-screen.ts` — `subscribe()` · handed the number (option b), never reaches for it\n\n```ts\nsubscribe(bus: EventBus<GameEvents>): void {\n  bus.on('game:over', (e) => {\n    this.active = true;\n    this.score = e.score; // handed to us in the payload — we never reach for it\n  });\n}\n```\n\n<style scoped>section { font-size: 22px; } pre { font-size: 0.68em; margin: 0.3em 0; } p { margin: 0.4em 0; }</style>\n"
    },
    {
      "name": "Mermaid UML diagram",
      "x": 100,
      "y": 80,
      "text": "```mermaid\ngraph LR\n  M[Marpit framework] --> C{Marp Core}\n  C --> CLI[Marp CLI]\n  C --> VS[Marp for VS Code]\n  C --> O[[Your own app]]\n```\n\n<style scoped>\nsvg[data-marp-mermaid] { width: 100%; height: auto; max-height: 540px; }\n</style>"
    }
  ]
}
