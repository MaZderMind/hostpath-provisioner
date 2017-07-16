# Copyright 2016 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

IMAGE?=mazdermind/hostpath-provisioner

TAG_GIT=$(IMAGE):$(shell git rev-parse HEAD)
TAG_LATEST=$(IMAGE):latest

all: dependencies hostpath-provisioner image

image:
	docker build -t $(TAG_GIT) -f Dockerfile.scratch .
	docker tag $(TAG_GIT) $(TAG_LATEST)

push:
	docker push $(TAG_GIT)
	docker push $(TAG_LATEST)

update-deployment:
	kubectl set image --namespace=kube-system deployment/hostpath-provisioner hostpath-provisioner=$(TAG_GIT)

dependencies:
	glide install -v

hostpath-provisioner: $(shell find . -name "*.go")
	CGO_ENABLED=0 go build -a -ldflags '-extldflags "-static"' -o hostpath-provisioner .

clean:
	rm -rf vendor
	rm hostpath-provisioner

.PHONY: all clean image push dependencies update-deployment
