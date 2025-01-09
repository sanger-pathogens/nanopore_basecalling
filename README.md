# Nanopore Basecalling

This repository is for the nextflow code used for basecalling Nanopore data from either pod5 or fast5 formats.

## Installation

1. [Install Nextflow](https://www.nextflow.io/docs/latest/install.html)

2. [Install Docker](https://docs.docker.com/engine/install/)

3. Download the appropriate Dorado installer from the [repo](https://github.com/nanoporetech/dorado#installation). The path to the executable will be `<path to downloaded folder>/bin/dorado`

4. (Optional) Download the appropriate Dorado model from the [repo](https://github.com/nanoporetech/dorado/#available-basecalling-models)

   ```
   # Download all models
   dorado download --model all
   # Download particular model
   dorado download --model <model>
   ```

   If a pre-downloaded model path is not provided to the pipeline, the model specified by the `--basecall_model` parameter will be downloaded on the fly. The default is set to "dna_r10.4.1_e8.2_400bps_hac@v4.3.0", other options available at https://github.com/nanoporetech/dorado.

## Usage

```
nextflow run nanopore-basecalling/main.nf \
--raw_read_dir <directory containing FAST5/POD5 files> \
--additional_metadata <CSV mapping sample IDs to barcodes> \
```

For further configuration, see the `ONT_BASECALLING` [subworkflow's own documentation](assorted-sub-workflow/ont_basecalling/README.md).