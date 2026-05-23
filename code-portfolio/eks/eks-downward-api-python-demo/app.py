#!/usr/bin/env python3
"""
Print real Kubernetes/EKS-adjacent values visible from inside a pod.

Most values come from Kubernetes Downward API environment variables wired
in deployment.yaml. A few values may exist by default in Kubernetes pods.
"""

import json
import os
from pathlib import Path


def emit(term: str, value, source: str, present: bool | None = None) -> None:
    if present is None:
        present = value not in (None, "")
    print(json.dumps({
        "event": "eks_term_observed",
        "term": term,
        "present": bool(present),
        "value": value if present else None,
        "source": source,
    }), flush=True)


def read_file(path: str) -> str | None:
    p = Path(path)
    if not p.exists():
        return None
    return p.read_text().strip()


def main() -> None:
    # Downward API env vars from deployment.yaml
    emit("pod", os.getenv("POD_NAME"), "downward_api_env:metadata.name")
    emit("namespace", os.getenv("POD_NAMESPACE"), "downward_api_env:metadata.namespace")
    emit("pod_uid", os.getenv("POD_UID"), "downward_api_env:metadata.uid")
    emit("node", os.getenv("NODE_NAME"), "downward_api_env:spec.nodeName")
    emit("serviceaccount", os.getenv("SERVICE_ACCOUNT"), "downward_api_env:spec.serviceAccountName")
    emit("pod_ip", os.getenv("POD_IP"), "downward_api_env:status.podIP")
    emit("host_ip", os.getenv("HOST_IP"), "downward_api_env:status.hostIP")

    # Values usually present in Kubernetes pods
    emit("container_hostname", os.getenv("HOSTNAME"), "default_env:HOSTNAME")
    emit("kubernetes_api", os.getenv("KUBERNETES_SERVICE_HOST"), "default_env:KUBERNETES_SERVICE_HOST")
    emit(
        "namespace_file",
        read_file("/var/run/secrets/kubernetes.io/serviceaccount/namespace"),
        "serviceaccount_mount:namespace",
    )

    # Optional: present when IRSA is configured for this service account
    emit("iam_irsa_role", os.getenv("AWS_ROLE_ARN"), "irsa_env:AWS_ROLE_ARN")
    emit("oidc_web_identity_token_file", os.getenv("AWS_WEB_IDENTITY_TOKEN_FILE"), "irsa_env:AWS_WEB_IDENTITY_TOKEN_FILE")
    emit("aws_region", os.getenv("AWS_REGION") or os.getenv("AWS_DEFAULT_REGION"), "aws_env:AWS_REGION/AWS_DEFAULT_REGION")

    # Optional examples: only present if you add ConfigMap/Secret wiring
    emit("configmap_example", os.getenv("APP_CONFIG"), "optional_env:APP_CONFIG")
    emit("secret_example", "set" if os.getenv("DB_PASSWORD") else None, "optional_env:DB_PASSWORD")


if __name__ == "__main__":
    main()
