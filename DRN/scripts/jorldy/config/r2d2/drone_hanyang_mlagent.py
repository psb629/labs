### R2D2 Atari Config ###

env = {"name": "drone_hanyang_mlagent", "render": True, "time_scale": 12.0}

agent = {
    "name": "r2d2",
    "network": "r2d2",
    "head": "cnn",
    "gamma": 0.997,
    "buffer_size": 1000000,
    "batch_size": 32,
    "clip_grad_norm": 40.0,
    "start_train_step": 50000,
    "target_update_period": 2500,
    "lr_decay": True,
    # MultiStep
    "n_step": 3,
    # PER
    "alpha": 0.9,
    "beta": 0.6,
    "uniform_sample_prob": 1e-3,
    # R2D2
    "seq_len": 16,
    "n_burn_in": 4,
    "zero_padding": True,
}

optim = {
    "name": "adam",
    "lr": 1e-4,
}

train = {
    "training": True,
    "load_path": None,
    "run_step": 30000000,
    "print_period": 10000,
    "save_period": 100000,
    "eval_iteration": 5,
    "record": False,
    "record_period": 300000,
    # distributed setting
    "distributed_batch_size": 256,
    "update_period": 16,
    "num_workers": 4,
}
