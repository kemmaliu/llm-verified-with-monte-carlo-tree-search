#!/bin/bash
#SBATCH --job-name=vmcts
#SBATCH --output=/n/holyscratch01/kempner_fellows/Users/dbrandfonbrener/vmcts/logs/%A_%a.out
#SBATCH --nodes=1              
#SBATCH --ntasks-per-node=1
#SBATCH --gpus-per-node=1    
#SBATCH --cpus-per-task=16
#SBATCH --time=8:00:00
#SBATCH --mem=250GB		
#SBATCH --account=kempner_fellows
#SBATCH --partition=kempner
#SBATCH --array=0-8

# Custom environment
source ~/.bashrc
conda deactivate
conda activate verify

export PYTHONPATH=.:${PYTHONPATH}

export model_arg_temp=0.6
export model_arg_topp=0.95
export model_arg_topk=0

export n_samples=1000 # may hit time limit before this


# Single problem for debugging
# export problem_here=problem_opt0
# export remove_hints=True
# export run_number=$[$SLURM_ARRAY_TASK_ID]

# Sweep across problems
export run_number=$[$SLURM_ARRAY_TASK_ID/9] # 100 runs per hyperparameter
export hyperparam_number=$[$SLURM_ARRAY_TASK_ID%9]

# export problem_names=(problem_opt0 problem_fact problem_opt0_opt problem_bst problem_repeat)
# export problem_names=(problem_unzip problem_days problem_food problem_lights problem_max_and_lists)

export problem_names=(problem_opt0_dafny_check problem_lights_more_check problem_fact_dafny_check problem_opt0_opt_dafny_check problem_repeat_dafny_check problem_bst_dafny_check problem_days_dafny_check problem_food_dafny_check problem_reverse_dafny_check)

export problem_here=${problem_names[$hyperparam_number]}

export language=Dafny

export base_model_name=Phind/Phind-CodeLlama-34B-v2
# export base_model_name=bigcode/starcoder2-15b-instruct-v0.1

if [ $problem_here == "problem_lights_more_check" ] || [ $problem_here == "problem_days_dafny_check" ] || [ $problem_here == "problem_food_dafny_check" ];
then
    export remove_hints=False # Note: these probs do not have hints anyways
else
    export remove_hints=True
fi

export WANDB_USERNAME=seas
export WANDB_PROJECT=vmcts
export WANDB_GROUP=whole-dafnychecks9-1
export WANDB_NAME=$problem_here/$run_number

SEED=$run_number

echo Using seed: $SEED
echo Run number: $run_number
echo Problem: $problem_here

python run_whole.py --seed=$SEED --use_wandb=True --wandb_entity=$WANDB_USERNAME --wandb_project=$WANDB_PROJECT --wandb_group=$WANDB_GROUP --wandb_name=$WANDB_NAME --model_arg_temp=$model_arg_temp --model_arg_topp=$model_arg_topp --model_arg_topk=$model_arg_topk --n_samples=$n_samples --problem_name=$problem_here --remove_hints=$remove_hints --language=$language --base_model_name=$base_model_name

