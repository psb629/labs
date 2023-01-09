from mlagents_envs.environment import UnityEnvironment
from mlagents_envs.environment import ActionTuple
from mlagents_envs.side_channel.engine_configuration_channel import EngineConfigurationChannel
from mlagents_envs.side_channel.environment_parameters_channel import EnvironmentParametersChannel

import numpy as np
import mlagents.trainers
import copy
import gym
from gym import spaces

import torch
import torch.nn as nn

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

class Drone_gym(gym.Env):
 #    def __init__(self, time_scale=2, filename='./DroneHanyang.exe', width=256, height=148):
    def __init__(self, time_scale=2, filename='/mnt/ext1/Drone/Linux/DroneHanyang.x86_64', width=256, height=148):
        port = np.random.randint(10000)
        self.engine_configuration_channel = EngineConfigurationChannel()
        self.environment_parameters_channel = EnvironmentParametersChannel()
        self.engine_configuration_channel.set_configuration_parameters(time_scale=time_scale, width=width, height=height)
        print(f"VERSION : {mlagents.trainers.__version__}")
        self.env = UnityEnvironment(
                file_name=filename,
                worker_id=port,
                side_channels=[self.engine_configuration_channel,
                               self.environment_parameters_channel])
        self.env.reset()
        
        self.observation_shape = (72, 128, 3)
        self.observation_space = spaces.Box(
            low = np.zeros(self.observation_shape), high = np.ones(self.observation_shape)*255, dtype = np.uint8)
        self.action_space = spaces.Box(
            low=-5, high=5, shape=(3,), dtype=np.float32
        )

        self.behavior_name = list(self.env.behavior_specs)[0]
        self.average_score = 0
        self.episode_count = 0
        self.curriculum_level = 0
        
        self.curriculum_parameters = [
                {"town_level": 0.0},
                {"town_level": 1.0},
                {"town_level": 2.0}
            ]
        self.environment_parameters_channel.set_float_parameter("town_level", 2.0)

    def reset(self):
        self.environment_parameters_channel.set_float_parameter("town_level", 2.0)
        self.env.reset()
        dec, _ = self.env.get_steps(self.behavior_name)
        state = [dec.obs[i][0] for i in range(len(dec.obs))]
        vec_info = state[1]
        x, y, z, tx, ty, tz, angle = vec_info
        self.last_staying_position = (x, y, z)
        self.staying_position = (x, y, z)
        self.steps = 0
        self.num_success = 0
        self.to_target_distance = np.sqrt((x-tx)**2 + (y-ty)**2 + (z-tz)**2)
        
#         ready_to_go = np.random.rand() <= 0.75
#         while not ready_to_go:
#             if (19.5<=tx<=19.6) and (0<=ty<=0.1) and (-11.75<=tz<=-11.7):
#                 ready_to_go = True
#             else:
#                 self.env.reset()
#                 dec, _ = self.env.get_steps(self.behavior_name)
#                 state = [dec.obs[i][0] for i in range(len(dec.obs))]
#                 vec_info = state[1]
#                 x, y, z, tx, ty, tz, angle = vec_info
        
        # random actions
        max_random_step = 30
        cur_step = 0
        while cur_step < max_random_step:
            action = np.random.randn(3) * 5
            next_obs, _, done, _ = self.step(action)
            cur_step += 1
            if done:
                cur_step = 0
                self.env.reset()
                dec, _ = self.env.get_steps(self.behavior_name)
                state = [dec.obs[i][0] for i in range(len(dec.obs))]
                vec_info = state[1]
                x, y, z, tx, ty, tz, angle = vec_info
                self.last_staying_position = (x, y, z)
                self.staying_position = (x, y, z)
                self.steps = 0
                self.num_success = 0
                self.to_target_distance = np.sqrt((x-tx)**2 + (y-ty)**2 + (z-tz)**2)

        next_obs = (np.array(copy.deepcopy(state)[0]) * 255).astype(np.uint8)
        
        return next_obs # (np.array(copy.deepcopy(next_obs)[0]) * 255).astype(np.uint8)
                             
    def step(self, action):
        
        self.steps += 1

        action_tuple = ActionTuple()
        action_tuple.add_continuous(np.array([action]))

        self.env.set_actions(self.behavior_name, action_tuple)
        self.env.step()

        dec, term = self.env.get_steps(self.behavior_name)

        done = len(term.agent_id)>0
        reward = term.reward[0] if done else dec.reward[0]
#         reward = np.clip(reward, -1,15).astype(np.float16)
        success = False
        if reward >=10: 
            success = True
        reward_sign = int(reward > 0)
        if done:
            next_state = [term.obs[i][0] for i in range(len(dec.obs))] # episode 종료시 next_state.
        else:
            next_state = [dec.obs[i][0] for i in range(len(dec.obs))] # episode 진행 중 next_state.
            
        # reward
        ## Is Agent close to the target
        vec_info = next_state[1]
        x, y, z, tx, ty, tz, angle = vec_info
        scope = 2 # 4 * (0.9**(self.num_success))
        tx_scope = tx-scope < x < tx + scope
        ty_scope = ty-scope < y < ty + scope
        tz_scope = tz-scope < z < tz + scope
        next_distance = np.sqrt((x-tx)**2 + (y-ty)**2 + (z-tz)**2)
        speed_to_target = self.to_target_distance - next_distance
        self.to_target_distance = next_distance
        # extra_reward for hard case
        extra_reward = (19.5<=tx<=19.6) and (0<=ty<=0.1) and (-11.75<=tz<=-11.7)
        
        next_state = (np.array(copy.deepcopy(next_state)[0]) * 255).astype(np.uint8)
        
        ## Target in sight
        r, g, b = 200, 70, 200
        rg = 50

        sample_r = np.where(next_state[:,:,0] <= r+rg, 1, 0) * np.where(r-rg <= next_state[:,:,0], 1, 0)
        sample_g = np.where(next_state[:,:,1] <= g+rg, 1, 0) * np.where(g-rg <= next_state[:,:,1], 1, 0)
        sample_b = np.where(next_state[:,:,2] <= b+rg, 1, 0) * np.where(b-rg <= next_state[:,:,2], 1, 0)

        sample_mask = sample_r*sample_g*sample_b
        
        ## Does Agent look at the target
        ox, oy = tz-z, tx-x
        target_angle = np.arctan2(oy, ox)/np.pi*180
        target_angle = target_angle if target_angle>=0 else 360 + target_angle
        angle_scope = int(abs(target_angle-angle)<=50)

        reward = sample_mask.sum()/np.ones_like(sample_mask).sum() + angle_scope * 0.01
        reward = max(reward - self.steps/100, 0)
        
        # Close to the target or not
        if (tx_scope and ty_scope and tz_scope) or success:
            reward += 1
            reward -= min(self.steps/100, 1)
#             reward += extra_reward
            if done:
                reward += (extra_reward+2)
                reward += (int(success) * 5)
                self.num_success += 1
        else:
            if done:
                reward -= next_distance/25
                
        if done:
            if self.episode_count==0:
                self.episode_count += 1
                self.average_score += reward
            else:
                self.episode_count += 1
                self.average_score = ((self.average_score * (self.episode_count - 1)) + reward)/self.episode_count
        
        if self.average_score > 10:
            self.curriculum_level = min(self.curriculum_level+1, 2)
        else:
            self.curriculum_level = max(self.curriculum_level-1, 0)
        
        for key, value in self.curriculum_parameters[np.random.randint(self.curriculum_level+1)].items():
            self.environment_parameters_channel.set_float_parameter(key, value)
            
        return next_state, reward*1.0, done, {}
    
    def close(self):
        self.env.close()

if __name__ == '__main__':

    import matplotlib.pyplot as plt
    env = Drone_gym(
            time_scale=5.0,
            filename='/mnt/ext1/Drone/Linux/DroneHanyang.x86_64')
    state = env.reset()
    done = False
    while not done:
        action = np.random.randn(3)
        _, _, done, _ = env.step(action)
