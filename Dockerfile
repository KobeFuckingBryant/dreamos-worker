# DreamOS custom worker: worker-comfyui + SeedVR2 restoration nodes.
# Base MUST stay -base-cuda12.8.1 — the only variant that boots on US-IL-1 4090s.
FROM runpod/worker-comfyui:5.8.6-base-cuda12.8.1

# SeedVR2 (ByteDance restorer, ICLR 2026) — the grit stage of the finish chain.
RUN comfy-node-install seedvr2_videoupscaler

# Weights live on the network volume (models/SEEDVR2/), which worker-comfyui does
# NOT auto-map (only classic subdirs) — this mapping makes ComfyUI see them.
COPY extra_model_paths.yaml /comfyui/extra_model_paths.yaml
