# Optimal Control of a Wave Energy Converter via Recurrent Reinforcement Learning

This repository contains the official implementation of an AI-driven control framework designed to maximize energy extraction efficiency for the Reference Model 3 (RM3) Wave Energy Converter (WEC) using Deep Reinforcement Learning.

## Project Overview
Maximizing power capture in WECs under irregular and stochastic ocean environments remains a fundamental challenge in ocean engineering. Conventional Control Methods, such as Model Predictive Control (MPC), heavily rely on simplified, linear hydrodynamic models. If these models have major or even minor modeling errors, the complex, non-linear ocean dynamics can drastically degrade the models' performance. 

To bridge this gap, this project proposes a model-free, sequence-learning control architecture that integrates **Proximal Policy Optimization (PPO)** with a **Long Short-Term Memory (LSTM)** recurrent network. By formulating the control loop as a Markov Decision Process (MDP), the agent learns to dynamically tune the Power Take-Off (PTO) damping coefficient in real time based on temporal wave patterns.

### Contributions
* **Temporal Sequence Learning**: Incorporates an LSTM layer to process historical time-series wave data (100-step history window), making the agent capture phase information and underlying wave trends.
* **Physics-Based Energy Efficiency (EE) Reward**: Introduces a normalized reward function mapping the ratio of average extracted power to the available wave energy flux. Since this scales with the magnitude of potential energy contained in the wave cycles, it remains robust across various wave conditions.
* **Custom Variable Carry-Over System**: Implements specialized boundary logic that transfers internal reward variables and observation histories between partitioned sub-episodes, ensuring seamless temporal learning over long sequences.

## Repository Structure

To ensure execution in MATLAB/Simulink without intricate path configuration, all primary executable scripts, simulation setups, and control logic are maintained directly within the root directory.

WEC_RL/                          # Project root directory
├── README.md                    # Project documentation and reproduction guide
├── 
├── 
│
# Train/Validation Scripts & Simulation Files (Kept in the root directory for easy execution)
├── 
├── 
├── 
├── 
├── 
├── 
│
# Data & Output Directories (Automated script outputs are directed here)
├── 
│   
│   
└── 

## Environment & Prerequisites
* **1. MATLAB (R2025a) / Simulink**
* **2. Required MATLAB Toolbox**: 
     * Reinforcement Learning
     * Deep Learning
     * Parallel Computing,
     * Statistics and Machine Learning
     * Control System
     * DSP system, 
     * Signal Processing
     * Simulink
     * Simulink Control Design
     * Simscape
     * Simscape Electrical
* **3. High-Performance Computing (HPC) with Slurm for parallel training.**


## How to Run
### Dataset Generation

### Training

### Validation



## Results & Performance

The model was validated against 200 diverse wave datasets. The results demonstrate:

| Metric | Fixed Damping (Baseline) | RL Controller (Ours) | Improvement |
| :--- | :---: | :---: | :---: |
| **Total Energy Extracted** | 3.1149e+08 J | 3.3810e+08 | **+ 8.54%**|
| **Capture Width Ratio (CWR)** | 23.69% | 25.71% | **+ 8.68%**  |  
| **Control Adaptibility** | Static | Dynamic & Real-time | N/A |

