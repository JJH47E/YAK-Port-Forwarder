## 1. Data Model

- [x] 1.1 Add `context: String?` field to `KubePortForwardResource` (default `nil`)
- [x] 1.2 Update `CodingKeys` to include `context`
- [x] 1.3 Update `encode(to:)` to use `encodeIfPresent` for `context`
- [x] 1.4 Update `init(from:)` to use `decodeIfPresent` for `context`
- [x] 1.5 Update `clone()` to copy the `context` field
- [x] 1.6 Update `applyChanges(from:)` to copy the `context` field

## 2. Context List in ViewModel

- [x] 2.1 Add `availableContexts: [String]` property to `KubeViewModel`
- [x] 2.2 Add a `fetchAvailableContexts()` method that runs `kubectl config get-contexts -o name` and parses the newline-separated output into `availableContexts`
- [x] 2.3 Call `fetchAvailableContexts()` inside the existing `load()` method (alongside the current-context fetch)

## 3. kubectl Command Construction

- [x] 3.1 Update `start()` in `KubePortForwardResource` to insert `--context <name>` into the arguments array when `self.context != nil`

## 4. UI — PortForwardForm

- [x] 4.1 Add `availableContexts: [String]` parameter to `PortForwardForm`
- [x] 4.2 Add a `Picker` labelled "Context" to the form, with a "System Default" option (`nil`) at the top followed by each name in `availableContexts`
- [x] 4.3 Bind the picker selection to `portForwardResource.context`

## 5. Wire Up Sheets

- [x] 5.1 Pass `viewModel.availableContexts` into `PortForwardForm` inside `AddPortForward`
- [x] 5.2 Pass `viewModel.availableContexts` into `PortForwardForm` inside `EditPortForward`
- [x] 5.3 In `AddPortForward`, set the new resource's `context` to `viewModel.context` (active context) before presenting the form, so the picker defaults to the active context

## 6. Verify

- [ ] 6.1 Open the Add sheet and confirm the context picker appears with all kubeconfig contexts and "System Default" at the top
- [ ] 6.2 Select a non-default context, create the resource, save and reopen the file — confirm the context is preserved
- [ ] 6.3 Open a `.yak` file that has no `context` key — confirm it loads without errors and behaves as before
- [ ] 6.4 Start a port-forward with a specific context selected and confirm `--context <name>` appears in the running process arguments
- [ ] 6.5 Start a port-forward with "System Default" selected and confirm no `--context` argument is present
