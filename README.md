# dreamos-worker
Custom [worker-comfyui](https://github.com/runpod-workers/worker-comfyui) image:
base `5.8.6-base-cuda12.8.1` + SeedVR2 restoration nodes + a volume mapping for
`models/SEEDVR2`. Contains only open-source software — no data, no weights.

Tags are immutable (hosts cache by tag): `seedvr2-v3` = SeedVR2 endpoint;
`talk-v1` = same image + `models/audio_encoders` mapping for the Wan2.2-S2V
talk endpoint. Bump the tag in build.yml for every new image.

`h3-v1` (2026-10-14) = ComfyUI pinned to v0.40.0 (native MiniMax H3 nodes) + cu128
torch for Blackwell (RTX PRO 6000) + `diffusion_models`/`text_encoders` mappings;
used by the `dreamos-eu-h3` endpoint. Later tags built from this Dockerfile inherit
the v0.40.0 pin.
