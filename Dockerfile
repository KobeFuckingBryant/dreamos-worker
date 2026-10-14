# DreamOS custom worker: worker-comfyui (+ SeedVR2 nodes up to talk-v1; h3-v1 = MiniMax H3).
# Base MUST stay -base-cuda12.8.1 — the only variant that boots on US-IL-1 4090s.
FROM runpod/worker-comfyui:5.8.6-base-cuda12.8.1

# h3-v1 (2026-10-14): ComfyUI pinned to v0.40.0 — the first release with native
# MiniMax H3 nodes (MiniMaxH3ImageToVideo / ReferenceToVideo / AddGuide) and the
# int8_convrot weight loader. Same commit the H3 test pod ran. The base's
# ComfyUI-Manager etc. are carried over; start.sh launches /comfyui/main.py with
# /opt/venv's python, so the new checkout's deps go into /opt/venv.
ARG COMFY_SHA=3541246a9c997f4b8c32f9f88f3c985d02021c79
RUN mv /comfyui /comfyui.base && \
    git clone --filter=blob:none https://github.com/comfyanonymous/ComfyUI.git /comfyui && \
    git -C /comfyui checkout ${COMFY_SHA} && \
    (cp -a /comfyui.base/custom_nodes/. /comfyui/custom_nodes/ || true) && \
    rm -rf /comfyui.base

# Torch for Blackwell (RTX PRO 6000, sm_120) needs a cu128 build >= 2.7; take the
# current cu128 wheels, then ComfyUI v0.40's own requirements.
RUN uv pip install --python /opt/venv/bin/python --upgrade torch torchvision torchaudio \
      --index-url https://download.pytorch.org/whl/cu128 && \
    uv pip install --python /opt/venv/bin/python -r /comfyui/requirements.txt && \
    for r in /comfyui/custom_nodes/*/requirements.txt; do \
      [ -f "$r" ] && uv pip install --python /opt/venv/bin/python -r "$r" || true; \
    done

# No SeedVR2 nodes in h3 images: comfy-node-install doesn't recognise the swapped
# v0.40.0 checkout, and the H3 endpoint never runs SeedVR2 (its own endpoint and
# image, seedvr2-v3, do). Build SeedVR2/talk tags from commit f5cf173 instead.

# Build-time load test: serverless worker logs are unreachable, so surface the
# node-import traceback IN THE BUILD LOG. Does not fail the build — diagnostic.
RUN python -c "import torch; print('torch', torch.__version__, 'cuda', torch.version.cuda)" && \
    git -C /comfyui log -1 --oneline && \
    grep -rqs "MiniMaxH3ImageToVideo" /comfyui/comfy_extras && echo "H3 nodes present" && \
    ls /comfyui/custom_nodes/ && cd /comfyui && \
    (timeout 300 python main.py --quick-test-for-ci --cpu 2>&1 || true) | \
    grep -iE "minimax|cannot import|import fail|traceback|error" | head -40

# Weights live on the network volume (models/SEEDVR2/), which worker-comfyui does
# NOT auto-map (only classic subdirs) — this mapping makes ComfyUI see them.
COPY extra_model_paths.yaml /comfyui/extra_model_paths.yaml
