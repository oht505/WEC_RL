Under Construction.

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

# Key Results & Impact

The model was validated against 200 diverse wave datasets. The results demonstrate:

| Metric | Fixed Damping (Baseline) | RL Controller (Ours) | Improvement |
| :--- | :---: | :---: | :---: |
| **Total Energy Extracted** | 3.1149e+08 J | 3.3810e+08 | **+ 8.54%**|
| **Capture Width Ratio (CWR)** | 23.69% | 25.71% | **+ 8.57%**  |  
| **Control Adaptibility** | Static | Dynamic & Real-time | N/A |

**Summary**: The RL agent achieved an **8.54%** increase in energy extraction efficiency, proving that intelligent, data-driven control is the future of sustainable ocean engineering.

# Techinical Stack
- MATLAB / Simulink
- High-Performance Computing (HPC) with Slurm for parallel training.
