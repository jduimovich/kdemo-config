all: 
	export TEKTON_DEMO_NS=tekton-pipelines
	export TEKTON_DEMO_SA=tekton-dashboard
	sh commit-push-build
