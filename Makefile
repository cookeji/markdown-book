default: publish

test:
	./make_summary.sh
	markdownlint -c options.config src

publish: test
	mdbook build --dest-dir docs

serve:
	mdbook serve --dest-dir docs
