{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.tabbyapi;

  toYAML = lib.generators.toYAML {};

  # Build configuration file content
  configFile = pkgs.writeText "config.yml" (toYAML (
    filterAttrs (n: v: v != null) {
      # Networking options
      network = filterAttrs (n: v: v != null) {
        host = cfg.host;
        port = cfg.port;
        disable_auth = cfg.disableAuth;
        disable_fetch_requests = cfg.disableFetchRequests;
        send_tracebacks = cfg.sendTracebacks;
        api_servers = cfg.apiServers;
      };

      # Logging options
      logging = filterAttrs (n: v: v != null) {
        log_prompt = cfg.logPrompt;
        log_generation_params = cfg.logGenerationParams;
        log_requests = cfg.logRequests;
      };

      # Sampling options
      sampling = filterAttrs (n: v: v != null) {
        override_preset = cfg.overridePreset;
      };

      # Developer options
      developer = filterAttrs (n: v: v != null) {
        unsafe_launch = cfg.unsafeLaunch;
        disable_request_streaming = cfg.disableRequestStreaming;
        cuda_malloc_backend = cfg.cudaMallocBackend;
        realtime_process_priority = cfg.realtimeProcessPriority;
      };

      # Model options
      model = filterAttrs (n: v: v != null) {
        model_dir = cfg.modelDir;
        inline_model_loading = cfg.inlineModelLoading;
        use_dummy_models = cfg.useDummyModels;
        dummy_model_names = if cfg.dummyModelNames != [] then cfg.dummyModelNames else null;
        model_name = cfg.modelName;
        use_as_default = if cfg.useAsDefault != [] then cfg.useAsDefault else null;
        max_seq_len = cfg.maxSeqLen;
        tensor_parallel = cfg.tensorParallel;
        gpu_split_auto = cfg.gpuSplitAuto;
        autosplit_reserve = if cfg.autosplitReserve != [] then cfg.autosplitReserve else null;
        gpu_split = if cfg.gpuSplit != [] then cfg.gpuSplit else null;
        rope_scale = cfg.ropeScale;
        rope_alpha = cfg.ropeAlpha;
        cache_mode = cfg.cacheMode;
        cache_size = cfg.cacheSize;
        chunk_size = cfg.chunkSize;
        max_batch_size = cfg.maxBatchSize;
        prompt_template = cfg.promptTemplate;
        vision = cfg.vision;
      };

      # Draft model options
      draft = filterAttrs (n: v: v != null) {
        draft_model_dir = cfg.draftModelDir;
        draft_model_name = cfg.draftModelName;
        draft_rope_scale = cfg.draftRopeScale;
        draft_rope_alpha = cfg.draftRopeAlpha;
        draft_cache_mode = cfg.draftCacheMode;
        draft_gpu_split = if cfg.draftGpuSplit != [] then cfg.draftGpuSplit else null;
      };

      # LoRA options
      lora = filterAttrs (n: v: v != null) {
        lora_dir = cfg.loraDir;
        loras = if cfg.loras != [] then cfg.loras else null;
      };

      # Embeddings options
      embeddings = filterAttrs (n: v: v != null) {
        embedding_model_dir = cfg.embeddingModelDir;
        embeddings_device = cfg.embeddingsDevice;
        embedding_model_name = cfg.embeddingModelName;
      };
    }
  ));

in {
  options.services.tabbyapi = {
    enable = mkEnableOption "TabbyAPI - An OAI compatible exllamav2 API";

    package = mkOption {
      type = types.package;
      default = pkgs.python3Packages.tabby-api;
      defaultText = literalExpression "pkgs.python3Packages.tabby-api";
      description = "The TabbyAPI package to use.";
    };

    # Networking options
    host = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "IP address to bind the server to.";
    };

    port = mkOption {
      type = types.port;
      default = 5000;
      description = "TCP port to listen on.";
    };

    disableAuth = mkOption {
      type = types.bool;
      default = false;
      description = "Disable API authentication.";
    };

    disableFetchRequests = mkOption {
      type = types.bool;
      default = false;
      description = "Prevent fetching external content during requests.";
    };

    sendTracebacks = mkOption {
      type = types.bool;
      default = false;
      description = "Send server tracebacks to client.";
    };

    apiServers = mkOption {
      type = types.listOf (types.enum ["OAI" "Kobold"]);
      default = ["OAI"];
      description = "API servers to enable. Possible values: OAI, Kobold.";
    };

    # Logging options
    logPrompt = mkOption {
      type = types.bool;
      default = false;
      description = "Log prompts to the console.";
    };

    logGenerationParams = mkOption {
      type = types.bool;
      default = false;
      description = "Log request generation options to the console.";
    };

    logRequests = mkOption {
      type = types.bool;
      default = false;
      description = "Log a request's URL, Body, and Headers to the console.";
    };

    # Sampling options
    overridePreset = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Start with the given sampler override preset from the sampler_overrides folder.";
    };

    # Developer options
    unsafeLaunch = mkOption {
      type = types.bool;
      default = false;
      description = "Skip dependency checks on startup.";
    };

    disableRequestStreaming = mkOption {
      type = types.bool;
      default = false;
      description = "Forcefully disable streaming requests.";
    };

    cudaMallocBackend = mkOption {
      type = types.bool;
      default = false;
      description = "Utilize PyTorch's CUDA memory allocation backend.";
    };

    realtimeProcessPriority = mkOption {
      type = types.bool;
      default = false;
      description = "Set process priority to highest available level.";
    };

    # Model options
    modelDir = mkOption {
      type = types.str;
      default = "/var/lib/tabbyapi/models";
      description = "Directory location for model files.";
    };

    inlineModelLoading = mkOption {
      type = types.bool;
      default = false;
      description = "Enable switching models via generation request parameter.";
    };

    useDummyModels = mkOption {
      type = types.bool;
      default = false;
      description = "Send dummy OAI model card for compatibility.";
    };

    dummyModelNames = mkOption {
      type = types.listOf types.str;
      default = ["gpt-3.5-turbo"];
      description = "Names to return in model endpoint responses.";
    };

    modelName = mkOption {
      type = types.str;
      description = "Folder name of model to load on startup.";
    };

    useAsDefault = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Keys applied by default across model loads.";
    };

    maxSeqLen = mkOption {
      type = types.nullOr types.ints.positive;
      default = null;
      description = "Maximum sequence length or context window.";
    };

    tensorParallel = mkOption {
      type = types.bool;
      default = false;
      description = "Enable tensor parallelism across GPUs.";
    };

    gpuSplitAuto = mkOption {
      type = types.bool;
      default = true;
      description = "Automatically distribute model across GPUs.";
    };

    autosplitReserve = mkOption {
      type = types.listOf types.ints.positive;
      default = [96];
      description = "Amount of empty VRAM (in MB) to reserve when loading with autosplit.";
    };

    gpuSplit = mkOption {
      type = types.listOf types.float;
      default = [];
      description = "Manual GB allocation across GPUs.";
    };

    ropeScale = mkOption {
      type = types.float;
      default = 1.0;
      description = "Adjustment for RoPE scale (or compress_pos_emb).";
    };

    ropeAlpha = mkOption {
      type = types.nullOr types.float;
      default = null;
      description = "RoPE alpha value; auto-calculated if unset.";
    };

    cacheMode = mkOption {
      type = types.enum ["FP16" "Q8" "Q6" "Q4"];
      default = "FP16";
      description = "Cache data type.";
    };

    cacheSize = mkOption {
      type = types.nullOr types.ints.positive;
      default = null;
      description = "Size of the K/V cache. Defaults to max_seq_len.";
    };

    chunkSize = mkOption {
      type = types.ints.positive;
      default = 2048;
      description = "Tokens processed per ingestion chunk.";
    };

    maxBatchSize = mkOption {
      type = types.nullOr types.ints.positive;
      default = null;
      description = "Maximum prompts processed simultaneously.";
    };

    promptTemplate = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Jinja2 template name from templates directory.";
    };

    vision = mkOption {
      type = types.bool;
      default = false;
      description = "Enable vision support for the provided model.";
    };

    # Draft model options
    draftModelDir = mkOption {
      type = types.str;
      default = "/var/lib/tabbyapi/models";
      description = "Directory for draft model files.";
    };

    draftModelName = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Folder name of draft model.";
    };

    draftRopeScale = mkOption {
      type = types.float;
      default = 1.0;
      description = "RoPE scaling for draft model.";
    };

    draftRopeAlpha = mkOption {
      type = types.float;
      default = 1.0;
      description = "RoPE alpha for draft model.";
    };

    draftCacheMode = mkOption {
      type = types.enum ["FP16" "Q8" "Q6" "Q4"];
      default = "FP16";
      description = "Draft model cache type.";
    };

    draftGpuSplit = mkOption {
      type = types.listOf types.float;
      default = [];
      description = "GB allocation for draft model across GPUs.";
    };

    # LoRA options
    loraDir = mkOption {
      type = types.str;
      default = "/var/lib/tabbyapi/loras";
      description = "Directory containing LoRA adapters.";
    };

    loras = mkOption {
      type = types.listOf (types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            description = "Folder name of LoRA adapter.";
          };
          scaling = mkOption {
            type = types.float;
            default = 1.0;
            description = "Application weight for LoRA adapter.";
          };
        };
      });
      default = [];
      description = "LoRA adapters to load with their scaling factors.";
    };

    # Embeddings options
    embeddingModelDir = mkOption {
      type = types.str;
      default = "/var/lib/tabbyapi/models";
      description = "Directory for embedding models.";
    };

    embeddingsDevice = mkOption {
      type = types.enum ["cpu" "cuda" "auto"];
      default = "cpu";
      description = "Processing device for embeddings.";
    };

    embeddingModelName = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Folder name of embedding model.";
    };

    # Additional service options
    user = mkOption {
      type = types.str;
      default = "tabbyapi";
      description = "User account under which TabbyAPI runs.";
    };

    group = mkOption {
      type = types.str;
      default = "tabbyapi";
      description = "Group under which TabbyAPI runs.";
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/tabbyapi";
      description = "Directory to store TabbyAPI data.";
    };

    extraArgs = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Additional command-line arguments to pass to TabbyAPI.";
      example = ["--some-flag" "--other-option=value"];
    };

    environmentFiles = mkOption {
      type = types.listOf types.path;
      default = [];
      description = ''
        Environment files to load for the service.
        Useful for API keys and other secrets.
      '';
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "torch"
      "nvidia-x11"
      "nvidia-persistenced"
      "cudatoolkit"
      "cuda_cudart"
      "cuda_cupti"
      "cuda_cuxxfilt"
      "cuda_nvml_dev"
      "cuda_nvrtc"
      "cuda_nvtx"
      "cuda_profiler_api"
      "cuda_sanitizer_api"
      "libcublas"
      "libcurand"
      "libcusolver"
      "libnvjitlink"
      "libcusparse"
      "libnpp"
      "libcufft"
      "cuda_cccl"
      "cuda_cuobjdump"
      "cuda_gdb"
      "cuda_nvcc"
      "cuda_nvdisasm"
      "cuda_nvprune"
      "nvidia-x11"
      "cudnn"
      "libcusparse_lt"
      "libcufile"
      "triton"
      "nvidia-settings"
    ];
    users.users = mkIf (cfg.user == "tabbyapi") {
      tabbyapi = {
        isSystemUser = true;
        group = cfg.group;
        home = cfg.dataDir;
        createHome = true;
        description = "TabbyAPI service user";
      };
    };

    users.groups = mkIf (cfg.group == "tabbyapi") {
      tabbyapi = {};
    };

    systemd.services.tabbyapi = {
      description = "TabbyAPI - OAI compatible exllamav2 API server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = cfg.dataDir;
        #EnvironmentFile = cfg.environmentFiles;

        ExecStartPre = pkgs.writeShellScript "tabbyapi-pre-start" ''
          # Create necessary directories
          mkdir -p ${cfg.modelDir}
          mkdir -p ${cfg.loraDir}
          mkdir -p ${cfg.embeddingModelDir}
          mkdir -p ${cfg.dataDir}/config

          # Copy config file
          rm -f ${cfg.dataDir}/config/config.yml
          cp ${configFile} ${cfg.dataDir}/config/config.yml
        '';

        ExecStart = ''
          ${cfg.package}/bin/tabbyapi \
            --config ${cfg.dataDir}/config/config.yml \
            ${escapeShellArgs cfg.extraArgs}
        '';

        Restart = "on-failure";
        RestartSec = "10s";

        # Resource limits
        LimitNOFILE = 65536;
      };
      environment = {
        # Ensure CUDA libraries are available
        LD_LIBRARY_PATH = lib.makeLibraryPath [
          pkgs.stdenv.cc.cc.lib
        ];
        CUDA_HOME="${pkgs.cudaPackages.cuda_nvcc}";
        TORCH_CUDA_ARCH_LIST="8.0;8.6;8.9;9.0;12.0";
      };
    };

    # Open firewall if not binding to localhost
    networking.firewall.allowedTCPPorts = mkIf (cfg.host != "127.0.0.1" && cfg.host != "localhost") [ cfg.port ];
  };
}
