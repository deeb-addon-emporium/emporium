# Deeb's Addon Emporium

Home-made addons for **WoW Forever** (the `_classic_beta_` client). Nothing here works on
Classic Era, TBC or retail, and it is not meant to.

## Get them with WowUp

1. Install [WowUp](https://wowup.io).
2. Settings → **Addon providers** → turn on **GitHub**.
3. Point WowUp at your WoW Forever install: the folder that contains `_classic_beta_`.
4. **Get Addons → Install from URL**, paste an addon's repo link from the list below.
5. Updates show up in WowUp's Updates tab like any other addon.

## The addons

See `catalogue.json` for the machine-readable list. Every addon lives at
`https://github.com/deebs-addon-emporium/<Name>`.

## For Mathew

`./publish.sh <Name>` pushes one addon from the local AddOns folder and cuts a release
if its `## Version` is new. `./publish-all.sh` does every addon in the catalogue.
The scripts refuse RXPGuides, RXPGuideImport, anything not `## Interface: 16001`, and any
folder that contains a purchased guide string.
