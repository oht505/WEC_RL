# Intelligent Wave Energy Control via Reinforcement Learning
**Maximizing energy extraction efficiency through adaptive PPO-LSTM control agents.**


# Project Overview
This project addresses a critical challenge in renewable energy: 

**How do we capture the maximum amount of energy from the unpredictable motion of ocean waves?**

Traditional Wave Energy Converters (WECs) often use fixed damping systems that cannot adapt to changing sea states. I developed a Deep Reinforcement Learning (DRL) framework that enables a controller to "learn" the optimal damping strategy in real-time, significantly outperforming conventional methods.

# Challenge:
- Non-linearity: Ocean waves (modeled via JONSWAP spectra) are irregular and inconsistent.
- Static Limitation: Fixed-damping controllers fail to adjust to different wave frequencies and heights, leading to wasted energy potential.

# Solution:
To solve this, I implemented an RL agent:

  - A Proximal Policy Optimization (**PPO**) agent.
  - Integrated Long-Short Term Memory (**LSTM**) layer to process time-series wave elevation data, allowing the agent to understand temporal patterns.
  - Real-time adjustment of the damping coefficient to maintain the optimal **Capture Width Ratio (CWR)**.
