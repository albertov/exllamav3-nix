# TabbyAPI Dependencies Mapping

This document maps the Python dependencies from TabbyAPI's pyproject.toml to their Nix package names.

## Runtime Dependencies (propagatedBuildInputs)

| Requirement | Nix Package | Notes |
|-------------|-------------|-------|
| fastapi-slim >= 0.115 | fastapi | Using full fastapi; dependency name removed via pythonRemoveDeps |
| pydantic == 2.11.0 | pydantic | Using nixpkgs version; version check removed via pythonRemoveDeps |
| ruamel.yaml | ruamel-yaml | Standard nixpkgs package |
| rich | rich | Standard nixpkgs package |
| uvicorn >= 0.28.1 | uvicorn | Standard nixpkgs package |
| jinja2 >= 3.0.0 | jinja2 | Standard nixpkgs package |
| loguru | loguru | Standard nixpkgs package |
| sse-starlette >= 2.2.0 | sse-starlette | Standard nixpkgs package |
| packaging | packaging | Standard nixpkgs package |
| tokenizers >= 0.21.0 | tokenizers | Standard nixpkgs package |
| formatron >= 0.4.11 | formatron | Custom package in overlay.nix |
| kbnf >= 0.4.1 | kbnf | Custom Rust-based package in pkgs/kbnf |
| aiofiles | aiofiles | Standard nixpkgs package |
| aiohttp | aiohttp | Standard nixpkgs package |
| async_lru | async-lru | Custom package in overlay.nix |
| huggingface_hub | huggingface-hub | Standard nixpkgs package |
| psutil | psutil | Standard nixpkgs package |
| httptools >= 0.5.0 | httptools | Standard nixpkgs package |
| pillow | pillow | Standard nixpkgs package |
| uvloop | uvloop | Standard nixpkgs package |

## Additional Dependencies

| Dependency | Nix Package | Purpose |
|------------|-------------|---------|
| pydantic-settings | pydantic-settings | Configuration management |
| httpx | httpx | HTTP client (may be used by some features) |
| exllamav2 | exllamav2 | Inference backend |
| exllamav3 | exllamav3 | Inference backend |

## Build Dependencies (nativeBuildInputs)

| Dependency | Nix Package | Purpose |
|------------|-------------|---------|
| setuptools | setuptools | Build system |
| wheel | wheel | Wheel creation |
| packaging | packaging | Version parsing (also runtime dep) |
| makeWrapper | makeWrapper | Creating executable wrapper |

## Notes

- **fastapi-slim**: Using the full `fastapi` package from nixpkgs instead of fastapi-slim. The "slim" variant excludes some optional dependencies, but using the full version ensures compatibility.

- **pydantic version**: TabbyAPI specifies pydantic == 2.11.0, but nixpkgs may have a slightly different version. We use `pythonRemoveDeps` to skip the version check since pydantic 2.x maintains API compatibility.

- **async_lru**: Not available in nixpkgs, so we build it from PyPI in overlay.nix.

- **formatron**: Not available in nixpkgs, so we build it from PyPI in overlay.nix with its dependencies (kbnf, general-sam, etc.).

- **kbnf**: A Rust-based Python package built from source in pkgs/kbnf with a Cargo.lock file.

- **general-sam**: A dependency of formatron, also a Rust-based Python package.
