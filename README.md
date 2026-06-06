# Optimal Control of a Wave Energy Converter via Recurrent Reinforcement Learning

This repository contains the official implementation of an AI-driven control framework designed to maximize energy extraction efficiency for the Reference Model 3 (RM3) Wave Energy Converter (WEC) using Deep Reinforcement Learning.

## Project Overview
Maximizing power capture in WECs under irregular and stochastic ocean environments remains a fundamental challenge in ocean engineering. Conventional Control Methods, such as Model Predictive Control (MPC), heavily rely on simplified, linear hydrodynamic models. If these models have major or even minor modeling errors, the complex, non-linear ocean dynamics can drastically degrade the models' performance. 

To bridge this gap, this project proposes a model-free, sequence-learning control architecture that integrates **Proximal Policy Optimization (PPO)** with a **Long Short-Term Memory (LSTM)** recurrent network. By formulating the control loop as a Markov Decision Process (MDP), the agent learns to dynamically tune the Power Take-Off (PTO) damping coefficient in real time based on temporal wave patterns.

### Contributions
* **Temporal Sequence Learning**: Incorporates an LSTM layer to process historical time-series wave data (100-step history window), making the agent capture phase information and underlying wave trends.
* **Physics-Based Energy Efficiency (EE) Reward**: Introduces a normalized reward function mapping the ratio of average extracted power to the available wave energy flux. Since this scales with the magnitude of potential energy contained in the wave cycles, it remains robust across various wave conditions.
* **Custom Variable Carry-Over System**: Implements specialized boundary logic that transfers internal reward variables and observation histories between partitioned sub-episodes, ensuring seamless temporal learning over long sequences.

#### PPO-LSTM Actor-Critic Architecture
<img width="694" height="544" alt="image" src="https://github.com/user-attachments/assets/1d704d6e-b471-44ab-81ea-29bc73c7efc1" />


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
├── createActorNetwork_lstm.m                  # Actor Network Architecture setting
├── createCriticNetwork_lstm.m                 # Critic Network Architecture setting
├── RM3_PPO_init_EE_lstm.m                     # Simulation parameter initialization file
├── plot_CompareEpisodeAgents.m                # Find best agents in each models and Plot the performance
├── plot_EpisodeReward_AvgEpisodeReward.m      # Plot episode reward and average episode reward with narrow window for one or more models
├── plot_eta_fex_damp.m                        # Plot water elevation, excitation forces, damping coefficient in Test simulation results
├── rm3_ss_0p1.mat                             # WEC simulator info 
├── run_generate_wave_data.mat                 # (Integrated) Create Training & Validation Dataset     
└── split_wave_dataset.m                       # Partitioning long wave time-series into smaller parts based on time settings (e.g., 1200s -> 20s x 60, 100s x 12)    
````

## How to Run

Since not all environments support HPC Slurm clusters, all procedures are designed to run sequentially within a local MATLAB environment using the provided scripts.

### Train & Validation Dataset Generation
1. Open and run `run_generate_wave_data.m` in MATLAB to generate the raw wave environment data.
    - The code will produce "Train_split20s_waveDataset_Hs3p66_Tp9p7_NW800_JN1000" folder and "Test_split20s_waveDataset_Hs3p66_Tp9p7_NW800_JN1000" folder as results of wave generation.
   
### Training
1. Before running main code for training, you may need to check every parameters in `RM3_PPO_init_EE_lstm.m` file to initialize the environment variables, hyperparameters, and the physics-based Energy Efficiency (EE) reward function parameters. Every MATLAB function blocks in the Simulink file 'RM3_PPO_Env_EE_lstm_main.slx' are also required to check whether parameters are correct or not.
2. Execute `RM3_PPO_Env_EE_lstm_main_train.m` to start training the PPO-LSTM agent. (RM3_PPO_init_EE_lstm.m will automatically be loaded by the main code)
   - This script interacts with the Simulink model (`RM3_PPO_Env_EE_lstm_main.slx`) and the state-space model data (`rm3_ss_0p1.mat`).
   - Training logs and checkpoint models will be saved locally in a designated directory (e.g., 'TrainedAgents_EE_lstm_...' and  `Training_Episode_EE_lstm_...`).
   - In the main code for training, episode agent models would be saved for every 100 episodes.
   - Notice!: Training Log Folder is quite large (e.g., 70GB). You keep in mind to make a space for that.   

### Validation 
1. Before running `PPO_validate_plot_EpisodeAgents_lstm.m` file, you need to set the name of model, Environment, the number of agents you want to validate.
2. To evaluate the control performance of the trained agent and visualize the results, run `PPO_validate_plot_EpisodeAgents_lstm.m`.
   - This script performs validation over the evaluation episodes sequentially in MATLAB without requiring any background shell (`.sh`) scripts.
   - After finishing all the process of validation code, you will see the folder "Validation_Results", and the name of models   

### (Optional) Plot
1. This may not be necessary but I uploaded the plotting code for convenience.


## Results & Performance

The model was validated against 200 diverse wave datasets. There are two evaluation metrics: Mean Cumulative Energy and Capture Width Ratio (CWR). Mean Cumulative Energy is the average of the total electricity energy extracted at the end of each evaluation epsiode across the 200 test wave profiles. CWR is to evaluate how effectively the device captures energy relative to the incoming wave power. The results demonstrate:

### Mean Cumulative Energy Comparison (Table) 
| Control | Mean Energy ($10^8$ J) | Improvement vs. Baseline ($%$)|
| :--- | :---: | :---: |
| Theoretical Maximum | 3.11 | - |
| Fixed-Damping (Baseline) | 6.30 | Base |
| Instantaneous Frequency (IF) | 3.37 | +8.36% |
| **Proposed PPO-LSTM** | **3.38** | **+8.68%** |

### Capture Width Ratio Comparison (Box plot)
<img width="388" height="425" alt="image" src="https://github.com/user-attachments/assets/fd8627bf-5f36-49eb-ab09-f65af9bde81f" />

### Detailed Control Action Analysis
<img width="718" height="402" alt="image" src="https://github.com/user-attachments/assets/9678035d-77ba-44f0-b925-2f9b38aada85" />

