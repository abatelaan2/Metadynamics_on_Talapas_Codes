#!/bin/bash
#SBATCH --partition=compute       ### queue to submit to
#SBATCH --job-name=run_FES_from_Reweighting       ### job name
#SBATCH --output=run_FES_from_Reweighting_jobout         ### file in which to store job stdout
#SBATCH --error=run_FES_from_Reweighting_joberr          ### file in which to store job stderr
#SBATCH --time=0-08:00:00        ### Wall clock time limit in HH:MM:SS
#SBATCH --nodes=1               ### number of nodes to use
#SBATCH --mem=32G
#SBATCH --ntasks-per-node=1    ### number of tasks to launch per node
#SBATCH --account=ch447_547      ### Account used for job submission

## Argument Instructions

### Parser stuff ###
#parser = argparse.ArgumentParser(description='calculate the free energy surfase (FES) along the chosen collective variables (1 or 2) using a reweighted kernel density estimate')
# files
#parser.add_argument('--colvar','-f',dest='filename',type=str,default='COLVAR',help='the COLVAR file name, with the collective variables and the bias')
#parser.add_argument('--outfile','-o',dest='outfile',type=str,default='fes-rew.dat',help='name of the output file')
# compulsory
#parser.add_argument('--sigma','-s',dest='sigma',type=str,required=True,help='the bandwidth for the kernel density estimation. Use e.g. the last value of sigma from an OPES_METAD simulation')
#kbt_group=parser.add_mutually_exclusive_group(required=True)
#kbt_group.add_argument('--kt',dest='kbt',type=float,help='the temperature in energy units')
#kbt_group.add_argument('--temp',dest='temp',type=float,help='the temperature in Kelvin. Energy units is Kj/mol')
# input columns
#parser.add_argument('--cv',dest='cv',type=str,default='2',help='the CVs to be used. Either by name or by column number, starting from 1')
#parser.add_argument('--bias',dest='bias',type=str,default='.bias',help='the bias to be used. Either by name or by column number, starting from 1. Set to NO for nonweighted KDE')
# grid related
#parser.add_argument('--min',dest='grid_min',type=str,help='lower bounds for the grid')
#parser.add_argument('--max',dest='grid_max',type=str,help='upper bounds for the grid')
#parser.add_argument('--bin',dest='grid_bin',type=str,default="100,100",help='number of bins for the grid')
# blocks
#split_group=parser.add_mutually_exclusive_group(required=False)
#split_group.add_argument('--blocks',dest='blocks_num',type=int,default=1,help='calculate errors with block average, using this number of blocks')
#split_group.add_argument('--stride',dest='stride',type=int,default=0,help='print running FES estimate with this stride. Use --blocks for stride without history') #TODO make this more efficient
# other options
#parser.add_argument('--deltaFat',dest='deltaFat',type=float,help='calculate the free energy difference between left and right of given cv1 value')
#parser.add_argument('--skiprows',dest='skiprows',type=int,default=0,help='skip this number of initial rows')
#parser.add_argument('--reverse',dest='reverse',action='store_true',default=False,help='reverse the time. Should be combined with --stride, without --skiprows')
#parser.add_argument('--nomintozero',dest='nomintozero',action='store_true',default=False,help='do not shift the minimum to zero')
#parser.add_argument('--der',dest='der',action='store_true',default=False,help='calculate also FES derivatives')
#parser.add_argument('--fmt',dest='fmt',type=str,default='% 12.6f',help='specify the output format')
# parse everything, for better compatibility

module load python3/3.10.13

mkdir fes_rew

python3 FES_from_Reweighting.py \
	--colvar COLVAR_Dipeptide_100ns \
	--sigma 0.1 \
	--temp 300 \
	--out fes_rew/fes_rew_${i}.dat \
	--cv phi \
	--stride 1000 \
	--deltaFat 0

: <<'END_COMMENT'

mkdir fes_rew

n_steps=427340
n_points=20

# Generate 20 evenly spaced indices
indices=()
for ((k=0; k<n_points; k++)); do
    index=$(( k * (n_steps - 1) / (n_points - 1) ))
    indices+=($index)
done

# Loop over the selected indices
for i in "${indices[@]}"; do
    python3 FES_from_Reweighting.py \
        --colvar COLVAR_merged \
        --sigma 0.1 \
        --temp 300 \
        --out fes_rew/fes_rew_${i}.dat \
        --cv dist \
        --skiprows $i \
        --deltaFat 2
done

END_COMMENT
