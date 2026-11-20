# Nemesis 2029 scenario — Bob and Alice robotics-resilience tool matrix

**Date:** 2026-11-20. **Scenario:** Fictional 2029 with drones, mobile quadrupeds, humanoid/animatronic robots, intermittent internet and a 4-GiB Intel MacBook Air running the Nemesis Operator edition. This is **planning, not a forecast of war or a claim that a robot is hostile**. The goal is safe observation, communication, access to information and response, not offensive action.

## Practical assignment

- **Bob, field observer:** offline maps, prepared emergency plans, safety-first visual checks, power kit, local mesh/phone communications and optional GNSS. Avoid relying on a single sensor or on constant internet access.
- **Alice, analyst/coordinator:** existing live aircraft globe, time-stamped local notes, passive receiver inventory, system health, manual alerts and optional Remote ID reception; never auto-interpret a detection as hostile intent.
- **Common carried equipment:** known-good USB Ethernet/tether adapter, verified charging and external battery, external LoRa node and ordinary phone if available, first-aid/contact card, offline map copies, weather protection and recovery media. The Mac is not a substitute for physical safety equipment.

## Transparent scoring (hypothetical)

The table scores **scenario relevance**, not observed usage. Each factor is an *analyst-assigned ordinal* 1–5: task need (40%), offline survivability (25%), 4-GiB Mac suitability (20%), and safe/maintainable operation (15%). Weighted average ×20 gives **0–100**. High scores do not automatically cause software installation: external sensors need compatible hardware and the user-mandated globe remains the default even though it requires internet.

| Tool/capability | Heuristic score /100 | Package decision | Primary role |
| --- | ---: | --- | --- |
| Offline emergency/safety checklist | 100 | Core proposal | Bob |
| Battery, thermal and device readiness | 100 | Core (present) | Alice |
| Off-grid short-text communications | 97 | External node | Bob |
| Offline maps and safe route notes | 96 | Core proposal | Bob |
| Timestamped local incident notebook | 92 | Core proposal | Alice |
| Local GNSS input | 85 | Hardware add-on | Bob |
| User-initiated camera observation | 80 | Hardware add-on | Bob |
| Broadcast Remote ID awareness | 78 | Hardware add-on | Alice |
| Full offline GIS/track planning | 72 | Advanced kit | Bob |
| Passive spectrum survey | 72 | Core, manual | Alice |
| Supplemental acoustic or thermal observation | 68 | Hardware add-on | Bob |
| ADS-B awareness for cooperative aircraft | 65 | Core, manual | Alice |
| Airplanes.live wallpaper | 52 | Core by design | Alice |
| Graphical SDR/DSP workstation | 47 | Advanced kit | Alice |
| Local object recognition model | 44 | Research hold | Alice |

**Missing measurements:** no empirical 2029 usage, no real operator survey, no sampled device recognition performance, no memory/thermal/CPU/battery benchmark on the target MacBook. Therefore **no statistical regression** or model-derived probabilities are defensible. After real device logs exist, compare per-capability session frequencies, active memory, average CPU, ISO dependency bytes, alert false-positive rate and recovery time before updating tiers.

## Robot types and what the laptop can or cannot infer

| Observed machine / failure | Useful, nonintrusive observations | What not to assume |
| --- | --- | --- |
| Compliant civilian drone | Broadcast Remote ID on supported hardware, visual confirmation, manual safety report | Remote ID shows only participating broadcasts; absence of a beacon does not establish an empty sky |
| Nonbroadcasting drone | Visual/acoustic observation and optional passive RF **metadata** where lawful | Aircraft might fly without remote links; no universal RF detector and no automatic classification of intent |
| Quadruped / mobile ground robot | Visual/thermal confirmation and distance/safety awareness; ordinary observation log | Commercial robot dogs can use onboard cameras/autonomy and need not advertise themselves as WLAN clients |
| Humanoid / animatronic platform | Human observation and physical hazard reporting | Appearance, noise and network signature alone do not prove identity or hostile behavior |
| Internet or GNSS disruption | Offline map, prepared contact plan, battery/USB diagnostics, off-grid messages, manual coordinates | Airplanes.live cannot substitute for an offline map or GNSS, and the live globe is not a robot detector |
| Mistaken identification | Human-in-the-loop uncertainty and source timestamps, privacy-aware logs | Do not trigger automated intervention, upload identifiable footage, or claim a danger classification without evidence |

The FAA states [Remote ID](https://www.faa.gov/uas/getting_started/remote_id) broadcasts identification/location for compliant aircraft. Its [detection guidance](https://www.faa.gov/airports/new_entrants/uas_detection_mitigation_response) distinguishes detection methods and emphasizes that systems do **not** establish the aircraft's intent. [NIST response-robot tests](https://www.nist.gov/programs-projects/performance-emergency-response-robots) treat sensing, mobility, communications, endurance, logistics and safety as separately testable capabilities; a single scanner cannot cover all of them. The [Boston Dynamics Spot specifications](https://support.bostondynamics.com/s/article/spot-specifications) offer a present-day quadruped example, not a prediction about 2029.

## What Nemesis should and should not preload

**Keep as the shipped Operator core:** battery/thermal/USB readiness, safe terminal/network tools, basic user-initiated RTL/Airspy/ADS-B, the Airplanes.live wallpaper with its current static offline fallback, and usable KDE/Firefox. These are already part of the source design and must not be displaced by an unreviewed scenario.

**Next lightweight source-design priorities:** an *actual* offline map viewer with legally obtained local data, a local incident notebook/checklist with no cloud dependency, and companion integration for off-grid LoRa messaging. None is implemented by writing this matrix. The offline standby HTML currently contains no real map. Consider existing Arch [QMapShack](https://archlinux.org/packages/extra/x86_64/qmapshack/) only after measuring its GDAL/Qt WebEngine dependency closure; do not install the whole GIS stack in core based on the name.

**Keep opt-in:** hardware-specific GNSS and Remote ID reception (the [OpenDroneID Android example](https://github.com/opendroneid/receiver-android) runs on compatible phone hardware, not an assumed Linux package), lawful passive RF metadata/spectrum tools, user-operated camera/thermal accessories, Gqrx/GNU Radio, QGIS, and offline vision experiments. Avoid creating background scans, telemetry uploads or presumed-hostile target lists.

**Do not bundle:** jamming, spoofing, takeover or automated robot/drone disruption capabilities. Detection data should not be used to identify, pursue or attack people. Published drone-mitigation authorities and airspace rules differ from ordinary observation and are not a general consumer privilege.

## Implementation gates and handoff

| ID | Deliverable and acceptance | Current status |
| --- | --- | --- |
| R29-01 | This versioned scenario scoring JSON and document with clear evidence links and uncertainty | SOURCE COMMITTED, CI CHECK PENDING |
| R29-02 | Per-tool *actual* CPU/RAM/dependency/uptime telemetry and operator usage counts | **NOT TESTED** |
| R29-03 | Offline map + signed, lightweight geodata pipeline, feature-level tests without internet | **NOT IMPLEMENTED** |
| R29-04 | Optional off-grid message companion and GPS/Remote ID interoperability, privacy review | **NOT IMPLEMENTED** |
| R29-05 | Real MacBook Air power, Wi-Fi recovery, sensor and graphical runtime checks | **DEFERRED** |

See [operator-kit contract](../../spec/operator-kits.json) and [original package matrix](OPERATOR_PACKAGE_LIT_MATRIX.md). No package manifests, image defaults, service policies, or local hardware were changed by this scenario review.
