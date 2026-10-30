# Code Signing & `.ipa` Release

This repo's default CI (`.github/workflows/build.yml`) builds **unsigned** for the
iOS Simulator — no Apple account needed, nothing installable.

To produce a **signed, installable `.ipa`** and attach it to a GitHub Release, use
`.github/workflows/release.yml`. It stays inert until you add the secrets below.

---

## 1. Prerequisites

- **Apple Developer Program** membership ($99/yr) — https://developer.apple.com/programs/
- Your app's **Bundle ID** registered: `com.kewaii.iOSDemo`
  (Certificates, Identifiers & Profiles → Identifiers → +)
- A **Distribution certificate** and a matching **provisioning profile**.

---

## 2. Export the signing assets (on a Mac, once)

### Distribution certificate → `.p12`
1. Xcode → Settings → Accounts → your team → **Manage Certificates** → + → **Apple Distribution**.
2. **Keychain Access** → My Certificates → right-click the *Apple Distribution* cert → **Export** → save as `cert.p12`, set a password.

### Provisioning profile → `.mobileprovision`
- developer.apple.com → Profiles → + → **App Store** (or **Ad Hoc** for direct install) → select the App ID + the Distribution cert → download `profile.mobileprovision`.

### Base64-encode both (for GitHub secrets)
```bash
base64 -i cert.p12 | pbcopy            # → BUILD_CERTIFICATE_BASE64
base64 -i profile.mobileprovision | pbcopy   # → PROVISIONING_PROFILE_BASE64
```

---

## 3. Add repo secrets

`Settings → Secrets and variables → Actions → New repository secret`:

| Secret | Value |
|---|---|
| `BUILD_CERTIFICATE_BASE64` | base64 of `cert.p12` |
| `P12_PASSWORD` | password you set on the `.p12` |
| `PROVISIONING_PROFILE_BASE64` | base64 of `.mobileprovision` |
| `KEYCHAIN_PASSWORD` | any random string (temp keychain password) |
| `APPLE_TEAM_ID` | your 10-char Team ID (Membership page) |

---

## 4. Set the export method

Edit `ExportOptions.plist` → `method`:

- `app-store` — upload to App Store Connect / TestFlight.
- `ad-hoc` — install on devices whose UDIDs are in the profile.
- `development` — dev-signed, registered devices only.

Set `teamID` to your Team ID (or leave `$APPLE_TEAM_ID` substitution as wired in the workflow).

---

## 5. Cut a release

```bash
git tag v1.1.0
git push origin v1.1.0
```

`release.yml` triggers on `v*` tags: imports the cert into a temporary keychain,
installs the profile, `xcodebuild archive` + `-exportArchive`, then uploads the
`.ipa` to the GitHub Release for that tag.

---

## 6. TestFlight (optional)

After an `app-store` export, upload with:
```bash
xcrun altool --upload-app -f build/iOSDemo.ipa -t ios \
  --apiKey "$ASC_KEY_ID" --apiIssuer "$ASC_ISSUER_ID"
```
Use an **App Store Connect API key** (`.p8`) for CI instead of an Apple ID password.

---

## Notes / gotchas

- Keep the temporary keychain + profile cleanup step (the workflow deletes them) so
  secrets never persist on the runner.
- Cert/profile **expire** (cert ~1yr, profile ~1yr) — re-export and update secrets.
- Bundle ID in the profile **must** match `PRODUCT_BUNDLE_IDENTIFIER` in the project.
- Never commit `.p12`, `.mobileprovision`, or `ExportOptions.plist` containing real IDs if private — secrets only.
