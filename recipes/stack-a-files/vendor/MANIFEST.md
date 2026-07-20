# Vendored libraries — provenance manifest

Copied 2026-07-19 from `~/Claude_Code/Spencer_Compas_DS/vendor/`
(FlamencoCompas-DS v1.1.0, the proven Stack A reference project). These are
the kit's own copies — the kit no longer depends on that project existing.
Never replace from a CDN at build time; to upgrade, vendor new files here
and update this manifest (version + SHA-256) in the same commit.

| File | Version | SHA-256 |
|---|---|---|
| `babel.min.js` | Babel standalone 8.0.3 (verified via `Babel.version` under jsc) | `858442582493298e0767cdc8858b2637d5e3b54dee2699cf5aaab9df4abb03db` |
| `react.production.min.js` | React 18.3.1 (UMD production) | `d949f1c3687aedadcedac85261865f29b17cd273997e7f6b2bfc53b2f9d4c4dd` |
| `react-dom.production.min.js` | ReactDOM 18.3.1 (UMD production) | `35f4f974f4b2bcd44da73963347f8952e341f83909e4498227d4e26b98f66f0d` |

Verify integrity: `shasum -a 256 recipes/stack-a-files/vendor/*.js` and
compare against this table.
