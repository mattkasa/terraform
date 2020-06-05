# generate runs `go generate` to build the dynamically generated
# source files, except the protobuf stubs which are built instead with
# "make protobuf".
generate:
	GOFLAGS=-mod=vendor go generate ./...
	# go fmt doesn't support -mod=vendor but it still wants to populate the
	# module cache with everything in go.mod even though formatting requires
	# no dependencies, and so we're disabling modules mode for this right
	# now until the "go fmt" behavior is rationalized to either support the
	# -mod= argument or _not_ try to install things.
	GO111MODULE=off go fmt command/internal_plugin_list.go > /dev/null

# We separate the protobuf generation because most development tasks on
# Terraform do not involve changing protobuf files and protoc is not a
# go-gettable dependency and so getting it installed can be inconvenient.
#
# If you are working on changes to protobuf interfaces you may either use
# this target or run the individual scripts below directly.
protobuf:
	bash scripts/protobuf-check.sh
	bash internal/tfplugin5/generate.sh
	bash plans/internal/planproto/generate.sh

fmtcheck:
	@sh -c "'$(CURDIR)/scripts/gofmtcheck.sh'"

# disallow any parallelism (-j) for Make. This is necessary since some
# commands during the build process create temporary files that collide
# under parallel conditions.
.NOTPARALLEL:

.PHONY: fmtcheck generate protobuf
