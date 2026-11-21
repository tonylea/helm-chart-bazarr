# Changelog

All notable changes to this project will be documented in this file. See [commit-and-tag-version](https://github.com/absolute-version/commit-and-tag-version) for commit guidelines.

## [2.0.0](https://github.com/tonylea/helm-chart-bazarr/compare/v1.0.1...v2.0.0) (2026-11-21)

### ⚠ BREAKING CHANGES

* persistence.data is now a list of named mounts, each at
  /data/<name>, with at least one required.

### Features

* mount each data volume at /data/<name> ([c2ccf59](https://github.com/tonylea/helm-chart-bazarr/commit/c2ccf5992c9441ab12dae51e2fb4e614a02d48f6))

### Documentation

* show the chart's download count ([a44d734](https://github.com/tonylea/helm-chart-bazarr/commit/a44d734ed7b5382b06353aa0cadc834f33f8957a))

## [1.0.1](https://github.com/tonylea/helm-chart-bazarr/compare/v1.0.0...v1.0.1) (2026-11-21)

### Bug Fixes

* leave resource requests to whoever deploys the chart ([113bd9c](https://github.com/tonylea/helm-chart-bazarr/commit/113bd9c4ad330da2598db46d8c9ebccbffc45663))

### Documentation

* keep only the comments that record a decision ([a94d7f5](https://github.com/tonylea/helm-chart-bazarr/commit/a94d7f5e6af0677116cc4f92e54aa09b5c9e05da))
* keep the README to the fixed settings and what the chart needs ([3d380c0](https://github.com/tonylea/helm-chart-bazarr/commit/3d380c05d8421c91f73a45153896532cba79db56))

## 1.0.0 (2026-11-21)

### Features

* deploy Bazarr on Postgres, with claims for /config and its libraries in /data ([c5824ea](https://github.com/tonylea/helm-chart-bazarr/commit/c5824eacd4c0ba2872ef82b3215a0e6f577bba67))

### Documentation

* describe the chart, its values and how to contribute ([0f83380](https://github.com/tonylea/helm-chart-bazarr/commit/0f83380aab3cd2fb714ef4cf44342019e6955b19))
