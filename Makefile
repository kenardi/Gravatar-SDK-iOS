.PHONY: docs

dev:
	xed .

dev-example:
	xed Example/

docs:
	swift package generate-documentation
	cp -r .build/plugins/Swift-DocC/outputs/Gravatar.doccarchive docs/Gravatar.doccarchive

build:
	swift build

test:
	swift test

lint-pod:
	bundle install
	bundle exec pod lib lint Gravatar.podspec
