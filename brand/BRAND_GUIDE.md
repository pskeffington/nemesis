# Nemesis visual standard

The user-approved board is the baseline. Preserve its angular violet emblem, independently original cyber-raptor, purple dusk mountain/radio landscape, silver NEMESIS PROJECT title, cyan instruments, and dark navy backdrop.

## Color and typography
| Token | HEX | Role |
|---|---|---|
| primary | #883DFF | Emblem, focus, glow |
| accent | #00A8FF | Signals, links |
| background | #0B0E14 | Canvas |
| surface | #1B2230 | Panels |
| text | #D7D9DE | Body |
| high | #F0F1F7 | Display |
| muted | #93A4BA | Metadata |

Inter Display/Inter or openly licensed substitutes for UI, and normal system monospace for console. Do not commit font files.

## Source/exports rules
- Separate scalable emblem SVG from wordmark. Keep approximately 12% symbol clear space.
- Render a distinct square icon without illegible microtext, plus circular avatar and favicon.
- Test small sizes 16, 32, 48 and 64 px, alpha edges and wordmark clipping.
- Keep social header text inside mobile safe areas; validate against official crop guidance.
- Wallpapers must remain usable behind windows and dock; do not upscale tiny card previews as a substitute for a 4K illustration master.
- No implied affiliation with films, games, military organizations, or third-party trademarks.
- A desktop mockup cannot serve as proof of a real installed KDE theme, an ISO boot, or Mac device compatibility.

## Object state and accessible interaction contract

The eight brand icon masters (terminal, radio, database, location, drone, satellite, headphones and shield) are reused *byte-for-byte* in the Plasma Theme Inspector. Each is a selectable preview object, **not a shortcut to operate equipment**.

| State | Observable treatment |
|---|---|
| Idle | dark surface (#1B2230), muted border, visible icon and label |
| Hover | brighter navy surface, cyan border |
| Selected | violet surface and 2px primary/accent stroke; detail text changes |
| Pressed | darker plum surface, immediate feedback |
| Keyboard focus | 3px focus outline, 4px when strong focus enabled |
| Disabled | dimmed opacity while retaining label and semantic Button state |
| Alternate accent | cyan replaces purple selected/focus outlines |
| Reset | restores terminal, primary violet and normal focus |

Qt Quick Controls handle mouse/touch/keyboard activation. Every object has text and an accessible label; contrast and source-integrity checks run in CI. Avoid flashing animations or interaction that silently launches external processes; support reduced-motion users by keeping state changes immediate. Live Plasma rendering and HiDPI remain a separate physical acceptance gate.
