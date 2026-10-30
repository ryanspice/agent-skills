# Receipt Schema

Every route canary or update should produce a secret-free receipt with these fields or an equivalent:

    {
      "schema_version": 1,
      "run_id": "timestamp-or-provider-run-id",
      "lane": "worker-example",
      "requested": {
        "provider": "openrouter",
        "model": "exact/provider-model-id"
      },
      "selected": {
        "provider": "openrouter",
        "model": "exact/provider-model-id",
        "fallback_used": false
      },
      "profile": {
        "name": "profile-name",
        "config_sha256": "sha256-or-null"
      },
      "catalog": {
        "required": true,
        "fresh": true,
        "fetched_at": "timestamp-or-null"
      },
      "policy": {
        "cost_class": "free",
        "paid_fallback_blocked": true,
        "children_requested": false,
        "children_started": false
      },
      "capabilities": {
        "inference": "pass|fail|not-run",
        "tools": "pass|fail|not-run",
        "structured_output": "pass|fail|not-run",
        "multimodal": "pass|fail|not-run"
      },
      "result": {
        "status": "pass|fail|partial|not-run",
        "failure_class": null,
        "output_path": "path-or-null"
      }
    }

Never include prompts containing secrets, raw authorization headers, API-key values, .env contents, or private customer data. Empty output, in-band failure text, provider/model substitution, or a mismatched receipt fails the canary even if the process exits successfully.
