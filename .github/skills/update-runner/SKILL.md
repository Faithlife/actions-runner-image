---
name: update-runner
description: Updates the GitHub Actions Runner used by the Windows images to the latest version.
---

## Overview

`RUNNER_VERSION` and `RUNNER_DOWNLOAD_HASH` must be kept in sync in two Dockerfiles:
- `windows/Dockerfile`
- `windows/vs2026.Dockerfile`

## Step 1: Get the latest release metadata

Run this in the terminal to fetch the latest release and extract the version and Windows x64 SHA256 hash:

```powershell
$release = gh release view --repo actions/runner --json tagName,body | ConvertFrom-Json
$version = $release.tagName -replace '^v', ''
$hash = ($release.body -split '\r?\n' | Select-String "actions-runner-win-x64-$version\.zip" | Select-Object -First 1).Line -replace '^(\S+)\s+.*', '$1'
Write-Host "Version: $version"
Write-Host "Hash:    $hash"
```

The release body contains lines of the form `<sha256hex>  actions-runner-win-x64-<version>.zip`. The regex above extracts the leading hex string.

If `$hash` is empty or doesn't look like a 64-character hex string, inspect `$release.body` directly to find the correct line format and adjust the `Select-String` pattern accordingly.

## Step 2: Verify the values

Confirm before editing:
- `$version` should be a semver string like `2.321.0`
- `$hash` should be a 64-character lowercase hex string

## Step 3: Update the Dockerfiles

Replace the two `ARG` lines in both `windows/Dockerfile` and `windows/vs2026.Dockerfile`. The lines to replace look exactly like:

```
ARG RUNNER_VERSION=<old-version>
ARG RUNNER_DOWNLOAD_HASH=<old-hash>
```

Use multi_replace_string_in_file to update all four occurrences (two per file) in a single call.

## Step 4: Commit

```
git add windows/Dockerfile windows/vs2026.Dockerfile
git commit  -m "Update Windows runner to $version."
```
