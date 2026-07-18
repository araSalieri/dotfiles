# caelestia-schemes

Backup of custom caelestia colour schemes. **Not a stow package** — do not `stow caelestia-schemes`.

Caelestia only reads schemes from its own package data dir (`caelestia/utils/paths.py`:
`scheme_data_dir = cli_data_dir / "schemes"`), so there is no user-level override path.

Restore after a caelestia reinstall/upgrade:

```sh
sudo cp -r pureblack /usr/lib/python3.<ver>/site-packages/caelestia/data/schemes/
caelestia scheme set pureblack default
```
