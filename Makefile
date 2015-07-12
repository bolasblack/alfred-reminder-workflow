.PHONY: build

build :
	bundle install --standalone
	-[ ! -f q_workflow.scpt ] && curl https://raw.githubusercontent.com/qlassiqa/qWorkflow/master/compiled%20source/q_workflow.scpt > q_workflow.scpt
	osacompile -o update_cache.scpt update_cache.applescript
