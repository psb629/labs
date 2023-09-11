from mlagents_envs.environment import UnityEnvironment, ActionTuple
from mlagents_envs.side_channel.engine_configuration_channel import (
    EngineConfigurationChannel,
)
from mlagents_envs.side_channel.environment_parameters_channel\
                             import EnvironmentParametersChannel
                             
import numpy as np
from PIL import Image 
import platform, subprocess
from .base import BaseEnv

import copy

def match_build():
    os = platform.system()
    return {"Windows": "Windows", "Darwin": "Mac", "Linux": "Linux"}[os]


class _MLAgent(BaseEnv):
    """MLAgent environment.

    Args:
        env_name (str): name of environment in ML-Agents.
        render (bool): parameter that determine whether to render.
        time_scale (bool): parameter that determine frame time_scale.
    """

    def __init__(self, 
                 env_name, 
                 curriculum_threshold = [0.1, 0.3],
                 render=False, 
                 time_scale=12.0,
                 no_op=True,
                 gray_img=False,
                 img_width=128,
                 img_height=72,
                 skip_frame=4,
                 stack_frame=4, 
                 id=None, 
                 **kwargs):
        
        env_path = f"./core/env/mlagents/{env_name}/{match_build()}/{env_name}"
        id = (
            np.random.randint(65534 - UnityEnvironment.BASE_ENVIRONMENT_PORT)
            if id is None
            else id
        )

        graphic_available = False if subprocess.getoutput("which Xorg") == "" else True
        no_graphics = not (render and graphic_available)

        no_graphics = False
        
        engine_configuration_channel = EngineConfigurationChannel()
        self.environment_parameters_channel = EnvironmentParametersChannel()
        
        self.env = UnityEnvironment(
            file_name=env_path,
            side_channels=[engine_configuration_channel, self.environment_parameters_channel],
            worker_id=id,
            no_graphics=no_graphics,
        )

        self.env.reset()

        self.score = 0

        self.behavior_name = list(self.env.behavior_specs.keys())[0]
        self.spec = self.env.behavior_specs[self.behavior_name]

        self.is_continuous_action = self.spec.action_spec.is_continuous()

        engine_configuration_channel.set_configuration_parameters(time_scale=time_scale, width=540, height=360)
        dec, term = self.env.get_steps(self.behavior_name)

        self.gray_img = gray_img
        self.stack_frame = stack_frame
        self.num_channel = 1 if self.gray_img else 3
        
        self.stacked_state = np.zeros(
            [self.num_channel * stack_frame, img_height, img_width]
        )
        
        # assert isinstance(skip_frame, int) and skip_frame > 0
        # self.skip_frame = skip_frame
        # self.skip_frame_buffer = np.zeros(
        #     (2,) + self.env.observation_space.shape, dtype=np.uint8
        # )
        
        self.no_op = no_op
        self.no_op_max = 30
    
    def reset(self):
        self.score = 0
        self.env.reset()
        dec, term = self.env.get_steps(self.behavior_name)
        
        state = self.state_processing(dec.obs)
        self.stacked_state = np.tile(state[0], (self.stack_frame, 1, 1))
        state = np.expand_dims(self.stacked_state, 0)
        
        return state

    def step(self, action):
        action_tuple = ActionTuple()

        if self.is_continuous_action:
            action_tuple.add_continuous(action)
        else:
            action_tuple.add_discrete(action)

        self.env.set_actions(self.behavior_name, action_tuple)
        self.env.step()

        dec, term = self.env.get_steps(self.behavior_name)
        done = len(term.agent_id) > 0
        reward = term.reward if done else dec.reward
        
        next_state = (
            self.state_processing(term.obs) if done else self.state_processing(dec.obs)
        )

        self.stacked_state = np.concatenate(
            (self.stacked_state[self.num_channel :], next_state[0]), axis=0
        )
        
        self.score += reward[0]

        next_state, reward, done = map(lambda x: np.expand_dims(x, 0), [self.stacked_state, reward, [done]])

        return (next_state, reward, done[0])

    def state_processing(self, obs):
        return obs[0]

    def close(self):
        self.env.close()


class HopperMLAgent(_MLAgent):
    def __init__(self, **kwargs):
        env_name = "Hopper"
        super(HopperMLAgent, self).__init__(env_name, **kwargs)

        self.state_size = 19 * 4
        self.action_size = 3
        self.action_type = "continuous"


class PongMLAgent(_MLAgent):
    def __init__(self, **kwargs):
        env_name = "Pong"
        super(PongMLAgent, self).__init__(env_name, **kwargs)

        self.state_size = 8 * 1
        self.action_size = 3
        self.action_type = "discrete"


class DroneDeliveryMLAgent(_MLAgent):
    def __init__(self, **kwargs):
        env_name = "DroneDelivery"
        super(DroneDeliveryMLAgent, self).__init__(env_name, **kwargs)

        self.state_size = [[15, 72, 128], 95]
        self.action_size = 3
        self.action_type = "continuous"
        
    def state_processing(self, obs):
        vis_obs = []

        for _obs in obs:
            if len(_obs.shape) == 2:  # vector observation
                vec_obs = _obs
            else:  # visual observation
                vis_obs.append(_obs)

        # vis obs processing
        vis_obs = np.concatenate(vis_obs, axis=-1)
        vis_obs = np.transpose(vis_obs, (0, 3, 1, 2))
        vis_obs = (vis_obs * 255).astype(np.uint8)
                
        return [vis_obs, vec_obs]

class DroneHanyangMLAgent(_MLAgent):
    def __init__(self, **kwargs):
        env_name = "DroneHanyang"
        super(DroneHanyangMLAgent, self).__init__(env_name, **kwargs)

        self.state_size = [3 * 4, 72, 128]
        # self.action_size = 27
        # self.action_type = "discrete"
        
        self.action_size = 3
        self.action_type = "continuous"
        
        self.curriculum_level = 0
        self.curriculum_parameters = [
            {"town_level": 0},
            {"town_level": 1},
            {"town_level": 2}
        ]        
        
        self.change_curriculum_level(0)
        
        self.count_step = 0
        
    def state_processing(self, obs):
        vis_obs = []

        for _obs in obs:
            if len(_obs.shape) == 2:  # vector observation
                vec_obs = _obs
            else:  # visual observation
                vis_obs.append(_obs)

        # vis obs processing
        # im = Image.fromarray((255*vis_obs[0][0]).astype(np.uint8))
        # im.save("./testimg.png")
        
        vis_obs = np.concatenate(vis_obs, axis=-1)
        vis_obs = np.transpose(vis_obs, (0, 3, 1, 2))
        vis_obs = (vis_obs * 255).astype(np.uint8)

        return vis_obs

    def step(self, action):
        action_tuple = ActionTuple()

        # print(action)
        # print(type(action))
        
        # action = self.convert_action(action)
        
        # action = np.expand_dims(np.array(action), axis=0)
        
        action_tuple.add_continuous(action)

        self.env.set_actions(self.behavior_name, action_tuple)
        self.env.step()

        dec, term = self.env.get_steps(self.behavior_name)
        done = len(term.agent_id) > 0
        reward = term.reward if done else dec.reward

        if done:
            next_state = [term.obs[i][0] for i in range(len(dec.obs))] # episode 종료시 next_state.
        else:
            next_state = [dec.obs[i][0] for i in range(len(dec.obs))] # episode 진행 중 next_state.
            
        next_state_process = (
            self.state_processing(term.obs) if done else self.state_processing(dec.obs)
        )

        self.stacked_state = np.concatenate(
            (self.stacked_state[self.num_channel :], next_state_process[0]), axis=0
        )
        
        self.score += reward[0]
        
        success = False
        if reward >=10: 
            success = True
            
        ############################# reward adjust for drone env ###################################
        
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
        r, g, b = 102, 48, 170
        rg = 35

        sample_r = np.where(next_state[:,:,0] <= r+rg, 1, 0) * np.where(r-rg <= next_state[:,:,0], 1, 0)
        sample_g = np.where(next_state[:,:,1] <= g+rg, 1, 0) * np.where(g-rg <= next_state[:,:,1], 1, 0)
        sample_b = np.where(next_state[:,:,2] <= b+rg, 1, 0) * np.where(b-rg <= next_state[:,:,2], 1, 0)

        # ## Target in sight
        # r, g, b = 200, 70, 200
        # _range = 50

        # sample_r = np.where(next_state[:,:,0] <= r+_range, 1, 0) * np.where(r-_range <= next_state[:,:,0], 1, 0)
        # sample_g = np.where(next_state[:,:,1] <= g+_range, 1, 0) * np.where(g-_range <= next_state[:,:,1], 1, 0)
        # sample_b = np.where(next_state[:,:,2] <= b+_range, 1, 0) * np.where(b-_range <= next_state[:,:,2], 1, 0)

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

        next_state, reward, done = map(lambda x: np.expand_dims(x, 0), [self.stacked_state, [reward], [done]])
        
        self.count_step +=1 
        
        if self.count_step == 6000000:
            self.change_curriculum_level(1)
        elif self.count_step == 10000000:
            self.change_curriculum_level(2)
        
        return (next_state, reward, done)
    
    def change_curriculum_level(self, level):
        self.curriculum_level = level  
        print(f"the level has been changed --> {self.curriculum_level}")
        
        # curriculum learning 파라미터 값 수정
        for key, value in self.curriculum_parameters[self.curriculum_level].items():
            self.environment_parameters_channel.set_float_parameter(key, value)
            
        self.env.reset()

    def reset(self):
        self.score = 0
        self.env.reset()
        dec, term = self.env.get_steps(self.behavior_name)
        
        state_img = self.state_processing(dec.obs)
        self.stacked_state = np.tile(state_img[0], (self.stack_frame, 1, 1))
        state_img = np.expand_dims(self.stacked_state, 0)
        
        state_for_vec = [dec.obs[i][0] for i in range(len(dec.obs))]
        vec_info = state_for_vec[1]
        x, y, z, tx, ty, tz, angle = vec_info
        self.last_staying_position = (x, y, z)
        self.staying_position = (x, y, z)
        self.steps = 0
        self.num_success = 0
        self.to_target_distance = np.sqrt((x-tx)**2 + (y-ty)**2 + (z-tz)**2)
        
        return state_img
    
    def convert_action(self, action):
        if action == 0:
            return [-1, -1, -1]
        elif action == 1:
            return [-1, -1,  0]
        elif action == 2:
            return [-1, -1,  1]
        elif action == 3:
            return [-1,  0, -1]
        elif action == 4:
            return [-1,  0,  0]
        elif action == 5:
            return [-1,  0,  1]
        elif action == 6:
            return [-1,  1, -1]
        elif action == 7:
            return [-1,  1,  0]
        elif action == 8:
            return [-1,  1,  1]
        elif action == 9:
            return [ 0, -1, -1]
        elif action == 10:
            return [ 0, -1,  0]
        elif action == 11:
            return [ 0, -1,  1]
        elif action == 12:
            return [ 0,  0, -1]
        elif action == 13:
            return [ 0,  0,  0]
        elif action == 14:
            return [ 0,  0,  1]
        elif action == 15:
            return [ 0,  1, -1]
        elif action == 16:
            return [ 0,  1,  0]
        elif action == 17:
            return [ 0,  1,  1]
        elif action == 18:
            return [ 1, -1, -1]
        elif action == 19:
            return [ 1, -1,  0]
        elif action == 20:
            return [ 1, -1,  1]
        elif action == 21:
            return [ 1,  0, -1]
        elif action == 22:
            return [ 1,  0,  0]
        elif action == 23:
            return [ 1,  0,  1]
        elif action == 24:
            return [ 1,  1, -1]
        elif action == 25:
            return [ 1,  1,  0]
        elif action == 26:
            return [ 1,  1,  1]