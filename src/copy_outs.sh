set -eou pipefail

if [ $# -ne 2 ]; then
  echo "bash this.sh [sample_sheet] [dest_dir]"
  exit 1
fi

sample_id=$1
dest_dir=$2

sample_list=($(tail -n +2 samplesheet.csv | cut -d ',' -f1))

for sample_name in "${sample_list[@]}"; do
    echo "copying analysis/cellranger/$sample_name/outs -> $dest_dir/$sample_name"
    cp -R analysis/cellranger/$sample_name/outs $dest_dir/$sample_name
done