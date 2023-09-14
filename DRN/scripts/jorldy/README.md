cd jorldy

```
python main.py --async --config=config.ppo.drone_hanyang_mlagent
```

main.py -> run_mode.py
1. single_train
2. sync_distributed_train
3. async_distributed_train
4. evaluate

The error `libGL error: No matching fbConfigs or visuals found` can be fixed with:
```
export LIBGL_ALWAYS_INDIRECT=1
```

The error `libGL error: failed to load driver: swrast` can be fixed with:
```
sudo apt-get install -y mesa-utils libgl1-mesa-glx
```

- /core/env/__init__.py:

	- Env 

- /core/env/base.py:

	- BaseEnv
	
		- Step

- /core/env/mlagent.py:

	- MLAgent(BaseEnv)	// input image processing, reward processing, target RGB information, ...
