# Under Construction (Keep working on it now)

# Optimal Control of a Wave Energy Converter via Recurrent Reinforcement Learning

This repository contains the official implementation of an AI-driven control framework designed to maximize energy extraction efficiency for the Reference Model 3 (RM3) Wave Energy Converter (WEC) using Deep Reinforcement Learning.

## Project Overview
Maximizing power capture in WECs under irregular and stochastic ocean environments remains a fundamental challenge in ocean engineering. Conventional Control Methods, such as Model Predictive Control (MPC), heavily rely on simplified, linear hydrodynamic models. If these models have major or even minor modeling errors, the complex, non-linear ocean dynamics can drastically degrade the models' performance. 

To bridge this gap, this project proposes a model-free, sequence-learning control architecture that integrates **Proximal Policy Optimization (PPO)** with a **Long Short-Term Memory (LSTM)** recurrent network. By formulating the control loop as a Markov Decision Process (MDP), the agent learns to dynamically tune the Power Take-Off (PTO) damping coefficient in real time based on temporal wave patterns.

### Contributions
* **Temporal Sequence Learning**: Incorporates an LSTM layer to process historical time-series wave data (100-step history window), making the agent capture phase information and underlying wave trends.
* **Physics-Based Energy Efficiency (EE) Reward**: Introduces a normalized reward function mapping the ratio of average extracted power to the available wave energy flux. Since this scales with the magnitude of potential energy contained in the wave cycles, it remains robust across various wave conditions.
* **Custom Variable Carry-Over System**: Implements specialized boundary logic that transfers internal reward variables and observation histories between partitioned sub-episodes, ensuring seamless temporal learning over long sequences.


## Environment & Prerequisites
* **1. MATLAB (R2025a) / Simulink**
* **2. Required MATLAB Toolbox**: 
     * Reinforcement Learning
     * Deep Learning
     * Parallel Computing,
     * Statistics and Machine Learning
     * Control System
     * DSP system
     * Signal Processing
     * Simulink
     * Simulink Control Design
     * Simscape
     * Simscape Electrical
* **3. High-Performance Computing (HPC) with Slurm for parallel training.**


## Repository Structure

To ensure execution in MATLAB/Simulink without intricate path configuration, all primary executable scripts, simulation setups, and control logic are maintained directly within the root directory.
````
WEC_RL/                                        # Project root directory
├── functions/                                 # Utility functions for wave data generation, signal processing, and plotting
│    └── generate_wave_data.m                  # Generate wave time-series 
├── hydro/                                     # Ocean engineering hydrodynamics equation
├── PPO_validate_plot_EpisodeAgent_lstm.m      # Validation for agents' performance
├── README.md                                  # Project documentation and reproduction guide
├── RM3_PPO_Env_lstm_main.slx                  # Simulation Environment 
├── RM3_PPO_Env_lstm_main_train.m              # Main Training code
├── RM3_PPO_init_EE_lstm.m                     # Simulation parameter initialization file
├── rm3_ss_0p1.mat                             # WEC simulator  
├── split_wave_dataset.m                       # Partitioning long wave time-series into smaller parts based on time settings (e.g., 1200s -> 20s x 60, 100s x 12)     
└── valid_lstm.sh                              # Bash file for running 'PPO_validate_plot_EpisodeAgent_lstm.m' 
````

## How to Run
### Train & Validation Dataset Generation



### Training

### Validation

### Plot


## Results & Performance

The model was validated against 200 diverse wave datasets. The results demonstrate:

| Control | Mean Energy ($10^8$ J) | Improvement vs. Baseline ($%$)|
| :--- | :---: | :---: |
| Theoretical Maximum | 3.11 | - |
| Fixed-Damping (Baseline) | 6.30 | Base |
| Instantaneous Frequency (IF) | 3.37 | +8.36% |
| **Proposed PPO-LSTM** | **3.38** | **+8.68%** |

[AllComparison_CWR.pdf](https://github.com/user-attachments/files/28661078/AllComparison_CWR.pdf)




