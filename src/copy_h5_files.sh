set -eou pipefail

if [ $# -ne 1 ]; then
  echo "bash this.sh [sample_id]"
  exit 1
fi


sample_id=$1

##if [ ! -f analysis/cellranger/$sample_id/outs/raw_feature_bc_matrix.h5 ]; then
##    echo "$sample_id/outs/raw_feature_bc_matrix.h5" is not found!
##    exit 1
## fi

if [ ! -d analysis/cellranger/$sample_id/outs/raw_feature_bc_matrix ]; then
    echo "$sample_id/outs/raw_feature_bc_matrix" is not found!
    exit 1
fi

if [ ! -d analysis/cellranger/$sample_id/outs/filtered_feature_bc_matrix ]; then
    echo "$sample_id/outs/filtered_feature_bc_matrix" is not found!
    exit 1
fi

cp -R analysis/cellranger/$sample_id/outs/raw_feature_bc_matrix ./$sample_id\_raw_feature_bc_matrix

cp -R analysis/cellranger/$sample_id/outs/filtered_feature_bc_matrix ./$sample_id\_filtered_feature_bc_matrix