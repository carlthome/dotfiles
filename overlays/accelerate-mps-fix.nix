# Fix accelerate tests failing on macOS CI runners with limited GPU memory
final: prev: {
  python3Packages = prev.python3Packages.override {
    overrides = pfinal: pprev: {
      accelerate = pprev.accelerate.overridePythonAttrs (old: {
        disabledTests =
          (old.disabledTests or [ ])
          ++ prev.lib.optionals final.stdenv.hostPlatform.isDarwin [
            # MPS backend out of memory on CI runners
            "test_can_pickle_dataloader_0"
            "test_can_pickle_dataloader_1"
            "test_nested_hook"
            "test_save_load_model_use_pytorch"
            "test_save_load_model_use_safetensors"
            "test_save_load_model_use_safetensors_tied_weights"
            "test_save_load_model_with_hooks_use_pytorch"
            "test_save_load_model_with_hooks_use_safetensors"
            "test_disk_offload"
            "test_disk_offload_with_unused_submodules"
            "test_dispatch_model"
            "test_dispatch_model_and_remove_hook"
            "test_dispatch_model_copy"
            "test_dispatch_model_force_hooks"
            "test_dispatch_model_move_offloaded_model"
            "test_dispatch_model_tied_weights"
            "test_dispatch_model_with_non_persistent_buffers"
            "test_dispatch_model_with_unused_submodules"
            "test_load_checkpoint_and_dispatch"
            "test_load_checkpoint_and_dispatch_with_unused_submodules"
            "test_align_devices_as_cpu_offload"
            "test_attach_align_device_hook_as_cpu_offload"
            "test_attach_align_device_hook_as_cpu_offload_with_weight_map"
            "test_release_memory"
            "test_align_module_device_offloaded"
            "test_align_module_device_offloaded_nested"
            "test_get_state_dict_offloaded_model"
            "test_set_module_tensor_to_meta_and_gpu"
          ];
      });
    };
  };
}
