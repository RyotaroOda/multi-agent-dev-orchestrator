.PHONY: dev-env-init dev-env-check dev-env-setup audit-collect audit-evaluate audit-report audit-dispatch audit-smoke-local

dev-env-init:
	./scripts/dev_env_setup.sh --init-only

dev-env-check:
	./scripts/dev_env_check.sh

dev-env-setup:
	./scripts/dev_env_setup.sh

audit-collect:
	GH_TOKEN=$$(./scripts/github_app_token.sh) ./scripts/audit_collector.sh --repo RyotaroOda/multi-agent-dev-orchestrator --branch main --output var/state/collector-output.json

audit-evaluate:
	./scripts/audit_evaluator.sh --input var/state/collector-output.json --audit-id AUDIT-local-001 --run-id local-run-001 --app-slug multi-agent-orchestrator-bot > var/state/evaluator-output.json

audit-report:
	./scripts/audit_reporter.sh --collector var/state/collector-output.json --evaluator var/state/evaluator-output.json --mode manual --approver Integrator

audit-dispatch:
	./scripts/audit_dispatcher.sh --evaluator var/state/evaluator-output.json --mode manual --output-dir var/state

audit-smoke-local:
	./scripts/audit_fixture.sh --mode blocked --output var/state/collector-output.json
	./scripts/audit_evaluator.sh --input var/state/collector-output.json --audit-id AUDIT-local-smoke --run-id local-run-001 --app-slug multi-agent-orchestrator-bot > var/state/evaluator-output.json
	./scripts/audit_reporter.sh --collector var/state/collector-output.json --evaluator var/state/evaluator-output.json --mode manual --approver Integrator
	./scripts/audit_dispatcher.sh --evaluator var/state/evaluator-output.json --mode manual --output-dir var/state
