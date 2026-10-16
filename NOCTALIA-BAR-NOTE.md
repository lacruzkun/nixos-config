# Optional Noctalia bar square-corner change

To make the Noctalia bar square-edged too, edit your **existing** `config/noctalia/config.toml` and change the value in `[bar.main]` from:

```toml
radius = 14
```

to:

```toml
radius = 0
```

This is an optional manual edit; this patch intentionally does not include or replace your full Noctalia TOML file.
