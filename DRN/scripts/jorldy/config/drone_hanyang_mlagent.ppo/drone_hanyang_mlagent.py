### PPO Drone Delivery Config ###

env = {"name": "drone_hanyang_mlagent", "render": True, "time_scale": 3.0}

agent = {
    "name": "ppo",
    "network": "continuous_policy_value",
    "head": "cnn",
    # "head": "cnn_resnet",
    "gamma": 0.95,
    "batch_size": 32,
    "n_step": 128,
    "n_epoch": 3,
    "_lambda": 0.95,
    "epsilon_clip": 0.1,
    "vf_coef": 1.0,
    "ent_coef": 0.01,
    "clip_grad_norm": 1.0,
    "use_standardization": True,
    "lr_decay": False,
}

optim = {
    "name": "adam",
    "lr": 2.5e-4,
}

train = {
    "training": True,
    "load_path": "./logs/drone_hanyang_mlagent/ppo/20230311094756544355/",
    "run_step": 30000000,
    "print_period": 10000,
    "save_period": 500000,
    "eval_iteration": 3,
    "record": False,
    "record_period": 1000000,
    # distributed setting
    "distributed_batch_size": 256,
    "update_period": agent["n_step"],
    "num_workers": 5,
}
