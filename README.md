# Nanopore Basecalling

This repository is for the code used for basecalling Nanopore data in either pod5 or fast5 formats.

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

   If a pre-downloaded model path is not provided to the pipeline, the model specified by the `--basecall_model` parameter will be downloaded on the fly.

5. Clone the repository with required submodules

   ```
   git clone --recurse-submodules https://github.com/sanger-pathogens/long-read-ampliseq.git
   ```

## Usage

```
nextflow run long-read-ampliseq/main.nf \
--raw_read_dir <directory containing FAST5/POD5 files> \
--reference <reference fasta> \
--additional_metadata <CSV mapping sample IDs to barcodes> \
--dorado_local_path <absolute path to Dorado executable> \
-profile docker
```

instead of `-profile docker`, you can run the pipeline with `-profile laptop`. As well as enabling docker, the laptop profile allows the pipeline to be used offline by providing a local copy of a configuration file that is otherwise downloaded.

Should you need to run the pipeline offline, it is best to make use of pre-populated dependency caches. These can be created with any of the supported profiles (e.g. `-profile docker`) and involves running the pipeline once to completion. You will also need to provide a `--basecall_model_path` (see installation step 4)- the laptop profile includes a default local path for this, as well as `--dorado_local_path`.

You can override the default paths using the command line parameters directly when invoking nextflow or supplying an additional config file in which these parameters are set, using the `-c my_custom.config` nextflow option.

### Other parameters:

#### Basecalling

- --basecall = "true"
- --basecall_model = "dna_r10.4.1_e8.2_400bps_hac@v4.3.0"
- --basecall_model_path = ""
- --trim_adapters = "all"
- --barcode_kit_name = ["SQK-NBD114-24"] (currently this can only be edited via the config file)
- --read_format = "fastq"

#### Saving output files

- --save_fastqs = true
