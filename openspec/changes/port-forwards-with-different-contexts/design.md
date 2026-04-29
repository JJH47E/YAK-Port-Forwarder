## Context

Every `KubePortForwardResource` currently runs `kubectl port-forward` without specifying a context, so it implicitly uses whichever context is active in `~/.kube/config` at the time. Users who need simultaneous port forwards to different clusters (e.g. dev and staging) must repeatedly switch their global context or run a separate terminal session, which is error-prone and disruptive.

The change adds an optional `context` field to each port-forward resource and surfaces it as a picker in the creation/edit form, populated from `kubectl config get-contexts`.

## Goals / Non-Goals

**Goals:**
- Allow each port-forward resource to carry its own optional kubectl context override
- Populate the context picker from the actual kubeconfig at app load time (same timing as the existing context fetch)
- Pass `--context <name>` to the `kubectl port-forward` subprocess when a context is set
- Keep the `.yak` file format backwards-compatible (missing `context` key treated as nil → use system default)
- Default new resources to the currently active context

**Non-Goals:**
- Switching or managing kubectl contexts (this is a read-only feature; we display and use contexts, not create or delete them)
- Supporting multiple kubeconfig files or `KUBECONFIG` merging beyond what `kubectl` itself resolves
- Validating that the chosen context is reachable before attempting a port-forward
- Autocomplete for resource names or namespaces scoped to the selected context

## Decisions

### Decision 1: Fetch contexts via `kubectl config get-contexts -o name`

`kubectl config get-contexts -o name` outputs a bare newline-separated list of context names. This is simpler to parse than `kubectl config view --output json` (which requires JSON decoding of the full kubeconfig) and avoids a dependency on kubeconfig file paths.

Alternative considered: reading `~/.kube/config` directly as YAML. Rejected because it bypasses `KUBECONFIG` env var merging and is fragile against non-standard kubeconfig locations.

### Decision 2: `context: String?` on `KubePortForwardResource`; `nil` means "use system default"

A nil context omits `--context` from the kubectl invocation entirely, preserving existing behaviour for files created before this change. This is preferable to storing the active context name at open time, because the active context may change between sessions and we don't want saved files to silently break.

### Decision 3: Store `availableContexts: [String]` on `KubeViewModel`

The list of available contexts is global (not per-resource), fetched once at load time alongside the existing `current-context` fetch. `PortForwardForm` receives it via its parent sheet, the same way it already receives the `portForwardResource` binding. No new dependency injection mechanism is needed.

### Decision 4: Default for new resources = current active context

When `AddPortForward` creates a new `KubePortForwardResource.new()`, its `context` will be set to `viewModel.context` (the active context string already fetched). This gives new resources a sensible default without requiring the user to always pick from the dropdown.

### Decision 5: Picker shows all contexts; nil/"default" option at top

The picker will include an explicit "Use system default" option (represented by `nil`) at the top of the list, followed by all context names. This lets users explicitly clear a previously set context without deleting and recreating the resource.

## Risks / Trade-offs

- **Context list staleness**: contexts are fetched once at load time. If the user adds a new context to kubeconfig while the app is open, it won't appear in the picker until the file is reopened. → Acceptable for v1; a refresh button can be added later.
- **Context picker on a running forward**: editing is disabled while a forward is running, so the picker can't be changed on an active process. No special handling needed.
- **Long context name lists**: users with many clusters will see a long picker. → No mitigation in this change; a search field is a future enhancement.
- **Backwards compatibility**: `.yak` files without a `context` key decode cleanly because `context` is `String?` and decoded with `decodeIfPresent`. Existing files continue to work unchanged.

## Migration Plan

No migration required. The `context` field uses `encodeIfPresent` / `decodeIfPresent`, so:
- Old files (no `context` key) open and behave exactly as before
- New files written with a context value are not readable by older app versions, but the field is simply ignored by any JSON decoder that doesn't know about it — no crash, just loss of the context setting
