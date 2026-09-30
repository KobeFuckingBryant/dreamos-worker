# dreamos-worker
Custom [worker-comfyui](https://github.com/runpod-workers/worker-comfyui) image:
base `5.8.6-base-cuda12.8.1` + SeedVR2 restoration nodes + a volume mapping for
`models/SEEDVR2`. Contains only open-source software — no data, no weights.

Tags are immutable (hosts cache by tag): `seedvr2-v3` = SeedVR2 endpoint;
`talk-v1` = same image + `models/audio_encoders` mapping for the Wan2.2-S2V
talk endpoint. Bump the tag in build.yml for every new image.
