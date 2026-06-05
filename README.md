# Optimal Control of a Wave Energy Converter via Recurrent Reinforcement Learning

This repository contains the official implementation of an AI-driven control framework designed to maximize energy extraction efficiency for the Reference Model 3 (RM3) Wave Energy Converter (WEC) using Deep Reinforcement Learning.

## Project Overview
Maximizing power capture in WECs under highly irregular and stochastic ocean environments remains a fundamental challenge in marine engineering. Conventional strategies, such as Model Predictive Control (MPC), heavily rely on simplified, linear hydrodynamic models that introduce severe modeling errors and suffer from performance degradation when subjected to complex, non-linear ocean dynamics.

To bridge this gap, this project proposes a model-free, sequence-learning control architecture that integrates **Proximal Policy Optimization (PPO)** with a **Long Short-Term Memory (LSTM)** recurrent network. By formulating the control loop as a Markov Decision Process (MDP), the agent learns to dynamically tune the Power Take-Off (PTO) damping coefficient in real time based on temporal wave patterns.

### Key Contributions & Features
* **Temporal Sequence Learning**: Incorporates an LSTM layer to interpret historical time-series wave data (100-step history window), enabling the agent to capture phase information and underlying wave trends.
* **Physics-Based Energy Efficiency (EE) Reward**: Introduces a normalized reward function mapping the ratio of average extracted power to the available wave energy flux. This prevents reward hacking and guarantees stable policy generalization across diverse wave scales.
* **Custom Variable Carry-Over System**: Implements specialized boundary logic that transfers internal reward variables and observation histories between partitioned sub-episodes, ensuring seamless temporal learning over long sequences.
* **Rigid Mechanical Safety**: Dynamically penalizes control updates that breach physical boundaries, strictly confining the relative float displacement within realistic hardware limits ($\pm2.5\text{m}$).
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
| **Capture Width Ratio (CWR)** | 23.69% | 25.71% | **+ 8.68%**  |  
| **Control Adaptibility** | Static | Dynamic & Real-time | N/A |



# Techinical Stack
- MATLAB / Simulink
- High-Performance Computing (HPC) with Slurm for parallel training.
