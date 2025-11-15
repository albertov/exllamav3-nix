# TabbyAPI NixOS Module

This module provides a NixOS service for running [TabbyAPI](https://github.com/theroyallab/tabbyAPI), an OAI-compatible API server for ExLlamaV2.

## Usage

### Adding to your flake

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    exllamav3-nix.url = "github:albertov/exllamav3-nix";
  };

  outputs = { self, nixpkgs, exllamav3-nix }: {
    nixosConfigurations.your-host = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        exllamav3-nix.nixosModules.tabbyapi
        ./configuration.nix
      ];
    };
  };
}
```

### Basic Configuration

Enable the service in your `configuration.nix`:

```nix
{ config, pkgs, ... }:

{
  services.tabbyapi = {
    enable = true;

    # Basic settings
    host = "0.0.0.0";  # Listen on all interfaces
    port = 5000;

    # Load a model on startup
    modelName = "my-model-name";
    modelDir = "/path/to/models";

    # Optional: Set max sequence length
    maxSeqLen = 4096;
  };
}
```

### Advanced Configuration

```nix
{ config, pkgs, ... }:

{
  services.tabbyapi = {
    enable = true;

    # Networking
    host = "0.0.0.0";
    port = 5000;
    apiServers = [ "OAI" "Kobold" ];

    # Model configuration
    modelName = "my-llama-model";
    modelDir = "/var/lib/tabbyapi/models";
    maxSeqLen = 8192;
    tensorParallel = true;
    gpuSplitAuto = true;
    autosplitReserve = [ 96 256 ];  # Reserve VRAM on each GPU

    # Cache settings
    cacheMode = "Q8";  # Use quantized cache for memory efficiency
    chunkSize = 2048;

    # Draft model for speculative decoding
    draftModelName = "my-draft-model";
    draftCacheMode = "Q4";

    # LoRA adapters
    loraDir = "/var/lib/tabbyapi/loras";
    loras = [
      { name = "adapter1"; scaling = 1.0; }
      { name = "adapter2"; scaling = 0.8; }
    ];

    # Embeddings
    embeddingModelName = "my-embedding-model";
    embeddingsDevice = "cuda";

    # Logging
    logPrompt = true;
    logGenerationParams = true;

    # Performance
    cudaMallocBackend = true;
    realtimeProcessPriority = true;

    # Security - use environment file for API keys
    environmentFiles = [ "/run/secrets/tabbyapi-env" ];
  };

  # Ensure model directory exists and has correct permissions
  systemd.tmpfiles.rules = [
    "d /var/lib/tabbyapi/models 0755 tabbyapi tabbyapi -"
    "d /var/lib/tabbyapi/loras 0755 tabbyapi tabbyapi -"
  ];
}
```

### Using with Different API Servers

```nix
services.tabbyapi = {
  enable = true;

  # Enable both OpenAI and Kobold API compatibility
  apiServers = [ "OAI" "Kobold" ];

  # For tools that expect OpenAI-compatible endpoints
  host = "0.0.0.0";
  port = 5000;

  # Use dummy models for compatibility with clients that check /v1/models
  useDummyModels = true;
  dummyModelNames = [ "gpt-3.5-turbo" "gpt-4" ];
};
```

### Vision Models

```nix
services.tabbyapi = {
  enable = true;
  modelName = "llava-model";
  vision = true;
  maxSeqLen = 4096;
};
```

### Inline Model Loading

```nix
services.tabbyapi = {
  enable = true;

  # Don't load a model on startup
  modelName = null;

  # Allow clients to specify which model to load
  inlineModelLoading = true;
  modelDir = "/var/lib/tabbyapi/models";
};
```

## Configuration Options

### Networking Options

- `host` - IP address to bind to (default: "127.0.0.1")
- `port` - TCP port to listen on (default: 5000)
- `disableAuth` - Disable API authentication (default: false)
- `disableFetchRequests` - Prevent fetching external content (default: false)
- `sendTracebacks` - Send server tracebacks to client (default: false)
- `apiServers` - API servers to enable: "OAI", "Kobold" (default: ["OAI"])

### Model Options

- `modelDir` - Directory for model files (default: "/var/lib/tabbyapi/models")
- `modelName` - Model to load on startup (default: null)
- `maxSeqLen` - Maximum sequence length/context window (default: null)
- `tensorParallel` - Enable tensor parallelism across GPUs (default: false)
- `gpuSplitAuto` - Automatically distribute model across GPUs (default: true)
- `autosplitReserve` - VRAM to reserve per GPU in MB (default: [96])
- `gpuSplit` - Manual GB allocation across GPUs (default: [])
- `ropeScale` - RoPE scaling factor (default: 1.0)
- `ropeAlpha` - RoPE alpha value (default: null, auto-calculated)
- `cacheMode` - Cache data type: "FP16", "Q8", "Q6", "Q4" (default: "FP16")
- `cacheSize` - K/V cache size (default: null, uses maxSeqLen)
- `chunkSize` - Tokens per ingestion chunk (default: 2048)
- `maxBatchSize` - Max simultaneous prompts (default: null)
- `promptTemplate` - Jinja2 template name (default: null)
- `vision` - Enable vision support (default: false)

### Draft Model Options

For speculative decoding:

- `draftModelDir` - Directory for draft models (default: "/var/lib/tabbyapi/models")
- `draftModelName` - Draft model to load (default: null)
- `draftRopeScale` - RoPE scaling for draft model (default: 1.0)
- `draftRopeAlpha` - RoPE alpha for draft model (default: 1.0)
- `draftCacheMode` - Draft model cache type (default: "FP16")
- `draftGpuSplit` - GB allocation for draft model (default: [])

### LoRA Options

- `loraDir` - Directory containing LoRA adapters (default: "/var/lib/tabbyapi/loras")
- `loras` - List of LoRA adapters with `name` and `scaling` attributes (default: [])

### Embeddings Options

- `embeddingModelDir` - Directory for embedding models (default: "/var/lib/tabbyapi/models")
- `embeddingsDevice` - Device for embeddings: "cpu", "cuda", "auto" (default: "cpu")
- `embeddingModelName` - Embedding model to load (default: null)

### Logging Options

- `logPrompt` - Log prompts to console (default: false)
- `logGenerationParams` - Log generation parameters (default: false)
- `logRequests` - Log request details (default: false)

### Developer Options

- `unsafeLaunch` - Skip dependency checks (default: false)
- `disableRequestStreaming` - Disable streaming (default: false)
- `cudaMallocBackend` - Use PyTorch CUDA memory backend (default: false)
- `realtimeProcessPriority` - Set highest process priority (default: false)

### Service Options

- `user` - User to run service as (default: "tabbyapi")
- `group` - Group to run service as (default: "tabbyapi")
- `dataDir` - Data directory (default: "/var/lib/tabbyapi")
- `extraArgs` - Additional CLI arguments (default: [])
- `environmentFiles` - Environment files for secrets (default: [])

## Security Considerations

1. **Authentication**: By default, TabbyAPI requires authentication. Only disable with `disableAuth = true` if running on a trusted network.

2. **Firewall**: The module automatically opens the configured port if not binding to localhost. Review your firewall settings.

3. **Secrets**: Use `environmentFiles` to load API keys and other secrets rather than hardcoding them in your configuration.

4. **User Isolation**: The service runs as a dedicated `tabbyapi` user with restricted permissions.

## Troubleshooting

### Check Service Status

```bash
systemctl status tabbyapi
```

### View Logs

```bash
journalctl -u tabbyapi -f
```

### Verify Configuration

The generated config file is located at `/var/lib/tabbyapi/config/config.yml`

### GPU Access Issues

If you encounter GPU access errors, ensure:
1. NVIDIA drivers are properly installed
2. The `tabbyapi` user has access to GPU devices
3. CUDA libraries are available in the system

You may need to add the user to the `video` group:

```nix
users.users.tabbyapi.extraGroups = [ "video" ];
```

## Example: Complete Setup

```nix
{ config, pkgs, ... }:

{
  # Import the module
  imports = [
    # ... other imports
  ];

  services.tabbyapi = {
    enable = true;
    package = pkgs.python3Packages.tabby-api;

    # Network configuration
    host = "0.0.0.0";
    port = 5000;

    # Model settings
    modelDir = "/mnt/models";
    modelName = "Llama-2-70B-GPTQ";
    maxSeqLen = 8192;

    # Performance optimization
    tensorParallel = true;
    gpuSplitAuto = true;
    cacheMode = "Q8";
    cudaMallocBackend = true;

    # Enable logging for debugging
    logPrompt = false;  # Don't log prompts in production
    logGenerationParams = true;
  };

  # Ensure NVIDIA drivers are loaded
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;

  # Allow user to access GPUs
  users.users.tabbyapi.extraGroups = [ "video" ];
}
```

## License

This module follows the same license as the exllamav3-nix project.
