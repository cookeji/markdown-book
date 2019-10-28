default: test

test:
	./make_summary.sh
	markdownlint -c options.config src

publish:
	mdbook build --dest-dir docs

serve:
	mdbook serve --dest-dir docs
