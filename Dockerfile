# DreamOS custom worker: worker-comfyui + SeedVR2 restoration nodes.
# Base MUST stay -base-cuda12.8.1 — the only variant that boots on US-IL-1 4090s.
FROM runpod/worker-comfyui:5.8.6-base-cuda12.8.1

# SeedVR2 (ByteDance restorer, ICLR 2026) — the grit stage of the finish chain.
RUN comfy-node-install seedvr2_videoupscaler

# Belt-and-braces: comfy-node-install should handle deps, but the node failed to
# LOAD at runtime on v2 ("Node not found") — install its requirements explicitly.
RUN SEEDVR_DIR=$(ls -d /comfyui/custom_nodes/*eedvr2* | head -1) && \
    pip install -r "$SEEDVR_DIR/requirements.txt"

# Build-time load test: serverless worker logs are unreachable, so surface the
# node-import traceback IN THE BUILD LOG. Does not fail the build — diagnostic.
RUN ls /comfyui/custom_nodes/ && cd /comfyui && \
    (timeout 300 python main.py --quick-test-for-ci --cpu 2>&1 || true) | \
    grep -iE "seedvr|cannot import|import fail|traceback|error" | head -40

# Weights live on the network volume (models/SEEDVR2/), which worker-comfyui does
# NOT auto-map (only classic subdirs) — this mapping makes ComfyUI see them.
COPY extra_model_paths.yaml /comfyui/extra_model_paths.yaml
