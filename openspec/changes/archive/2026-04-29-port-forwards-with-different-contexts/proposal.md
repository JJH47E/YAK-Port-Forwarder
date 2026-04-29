## Why

Currently every port-forward in YAK inherits the system's active `kubectl` context, making it impossible to forward ports to multiple clusters simultaneously. Users who work across several clusters (e.g., dev, staging, prod) must switch their global context between sessions rather than running the right resources side by side.

## What Changes

- Add an optional `context` field to `KubePortForwardResource`, storing the name of the kubectl context to use for that forward
- Populate the context dropdown by running `kubectl config get-contexts` at load time and parsing the available context names
- Update `PortForwardForm` (used in both Add and Edit sheets) to show a `Picker` with all available contexts, defaulting to the current active context for new resources
- Update the `kubectl port-forward` command construction to pass `--context <name>` when a specific context is set
- Persist the `context` field in the `.yak` JSON format

## Capabilities

### New Capabilities

- `per-resource-context`: Ability to assign a specific kubectl context to an individual port-forward resource, overriding the global active context

### Modified Capabilities

- `project`: The core resource model gains a new optional `context` field; the process execution domain changes command construction; the UI form gains a context picker

## Impact

- `Kube/KubePortForwardResource.swift`: add `context: String?` field; update `encode`/`decode`; update `kubectl` command construction to include `--context`
- `Kube/KubeViewModel.swift`: add `availableContexts: [String]` list; populate it at `load()` time via `kubectl config get-contexts`
- `Views/PortForwardForm.swift`: add context `Picker` bound to `portForwardResource.context`
- `Views/EditPortForward.swift` / `Views/AddPortForward.swift`: no structural changes needed (form drives the picker)
- `.yak` file format: backwards-compatible addition (`context` is optional; existing files without it continue to work)
