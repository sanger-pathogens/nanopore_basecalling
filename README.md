# nanopore_basecalling

[[_TOC_]]

## Pipeline overview

nanopore_basecalling is a Nextflow DSL2 pipeline for basecalling Oxford Nanopore sequencing data from raw signal files. It handles the full pre-processing chain from raw instrument output to demultiplexed, quality-controlled FASTQ files ready for downstream analysis.

The pipeline performs the following steps:

1. **Format conversion** — FAST5 files are converted to POD5 format using the `pod5` tool. POD5 files are passed through directly (after merging).
2. **Basecalling** — [Dorado](https://github.com/nanoporetech/dorado) calls bases from the merged POD5 file. A sequencing summary TSV is generated alongside the basecalled BAM.
3. **Demultiplexing** — if a barcode kit is specified, Dorado demuxes the basecalled BAM into per-barcode BAM files.
4. **Metadata assignment** — barcode BAMs are optionally joined to a user-supplied metadata CSV to assign sample IDs to barcodes.
5. **FASTQ conversion** — demultiplexed BAMs are converted to gzipped FASTQ files with Samtools (when `--read_format fastq`).
6. **QC** — PycoQC generates an interactive HTML quality report from the Dorado sequencing summary.

Basecalling requires a GPU (the pipeline submits GPU jobs on the Sanger HPC automatically via the `gpu` process label).

## Usage

### Quickstart

#### From source code

1. Clone this repository:

   ```bash
   git clone --recurse-submodules <repo-url>
   cd nanopore_basecalling
   ```

2. Install [Nextflow](https://www.nextflow.io/docs/latest/getstarted.html) (>=21.04.0) and a container runtime (Docker or Singularity).

3. Run the pipeline:

   ```bash
   nextflow run main.nf \
       -profile docker \
       --raw_read_dir /path/to/pod5_or_fast5_dir \
       --barcode_kit_name SQK-NBD114-24 \
       --outdir my_output
   ```

   Other profiles are also supported (`singularity`).
   :warning: If no profile is specified the pipeline will run with the Sanger HPC-specific configuration.

4. Once the run has finished successfully and you have inspected the output, clean up intermediate files. The `work/` directory and `.nextflow.log` are useful for troubleshooting — do not delete them until you are satisfied the outputs are correct:

   ```bash
   rm -rf work .nextflow*
   ```

   Alternatively, use `nextflow clean` for more fine-grained control over which runs and intermediate files are removed.

   See [Parameters](#parameters) for all available options.

#### Using on the Sanger farm

Load the latest pipeline module:

```bash
module load nanopore_basecalling
```

The `nanopore_basecalling` command is then available directly. To print the help:

```bash
nanopore_basecalling --help
```

Submit the pipeline to LSF (the pipeline will request GPU nodes automatically for the basecalling step):

```bash
bsub -o basecalling.o -e basecalling.e -q oversubscribed \
    -R "select[mem>4000] rusage[mem=4000]" -M4000 \
    nanopore_basecalling \
        --raw_read_dir /path/to/pod5_dir \
        --barcode_kit_name SQK-NBD114-24 \
        --outdir my_output
```

### Input

#### Raw read directory (`--raw_read_dir`)

A directory containing raw Oxford Nanopore signal files in either POD5 (`.pod5`) or FAST5 (`.fast5`) format. All files in the directory must be of the same format — mixed directories are not supported.

```
raw_reads/
  PAM00001_pass_barcode01_abc123.pod5
  PAM00001_pass_barcode02_abc123.pod5
  ...
```

#### Metadata CSV (`--additional_metadata`, optional)

A CSV file mapping sample IDs to barcode numbers, used to rename demultiplexed outputs:

```
ID,barcode
Sample1,01
Sample2,02
```

If not provided, output files are named using the barcode kit and barcode number.

#### Custom barcode files (`--barcode_arrangement`, `--barcode_sequences`, optional)

For custom barcoding kits, supply a TOML arrangement file and a FASTA barcode sequences file alongside `--barcode_kit_name`. See the [Dorado custom barcode documentation](https://github.com/nanoporetech/dorado/blob/release-v0.9/documentation/CustomBarcodes.md) for the required file formats.

### Output

Results are written to `--outdir` (default: `results`) with the following structure:

```
my_output/
  fastqs/                                    # Per-barcode gzipped FASTQ files (--read_format fastq and --save_fastqs true)
    <SampleID_or_kit_barcode>.fastq.gz
  bams/                                      # Per-barcode BAM files (--read_format bam)
    <SampleID_or_kit_barcode>.bam
  sequencing_summary/
    summary.tsv                              # Dorado sequencing summary (input to PycoQC)
  qc/
    pycoqc/
      summary_pycoqc.html                    # Interactive PycoQC QC report
      summary_pycoqc.json
```

### Parameters

**Basecalling**

| Option                    | Type      | Default | Description                                                                                                                                                                                                                             |
| ------------------------- | --------- | ------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `--raw_read_dir`          | `path`    | `""`    | Directory containing raw POD5 or FAST5 files (mandatory).                                                                                                                                                                               |
| `--model`                 | `string`  | `sup`   | Dorado basecalling model. Can be an accuracy level (`fast`, `hac`, `sup`) or a full model name (e.g. `dna_r10.4.1_e8.2_400bps_sup@v5.0.0`). See [Dorado model list](https://software-docs.nanoporetech.com/dorado/latest/models/list/). |
| `--min_qscore`            | `integer` | `9`     | Minimum Q-score filter applied during basecalling.                                                                                                                                                                                      |
| `--trim_adapters`         | `string`  | `all`   | Adapter/primer trimming mode. `all` trims any detected adapters or primers.                                                                                                                                                             |
| `--barcode_kit_name`      | `string`  | `null`  | Barcode kit used for multiplexing (e.g. `SQK-NBD114-24`). Required for demultiplexing.                                                                                                                                                  |
| `--modified_bases_models` | `string`  | `null`  | Comma-separated list of modified base models. Must match the basecalling model.                                                                                                                                                         |
| `--barcode_arrangement`   | `path`    | `null`  | Custom barcode arrangement TOML file. Requires `--barcode_kit_name` and `--barcode_sequences`.                                                                                                                                          |
| `--barcode_sequences`     | `path`    | `null`  | Custom barcode FASTA file. Requires `--barcode_kit_name` and `--barcode_arrangement`.                                                                                                                                                   |

---

**Output**

| Option          | Type      | Default   | Description                                                                         |
| --------------- | --------- | --------- | ----------------------------------------------------------------------------------- |
| `--read_format` | `string`  | `fastq`   | Output format for basecalled reads. One of: `fastq`, `bam`.                         |
| `--save_fastqs` | `boolean` | `true`    | Save FASTQ files to the output directory (only applies when `--read_format fastq`). |
| `--outdir`      | `path`    | `results` | Top-level output directory.                                                         |

---

**Metadata**

| Option                  | Type   | Default | Description                                                            |
| ----------------------- | ------ | ------- | ---------------------------------------------------------------------- |
| `--additional_metadata` | `path` | `null`  | CSV file with `ID,barcode` columns to assign sample names to barcodes. |

---

**General**

| Option              | Type      | Default | Description                  |
| ------------------- | --------- | ------- | ---------------------------- |
| `--monochrome_logs` | `boolean` | `false` | Disable coloured log output. |

### Advanced usage

#### Basecalling model selection

The `--model` parameter accepts either a shorthand accuracy level or a fully qualified model name:

```bash
# Use highest-accuracy (SUP) model — default
--model sup

# Use a specific versioned model
--model dna_r10.4.1_e8.2_400bps_sup@v5.0.0
```

Always ensure the model matches the flow cell chemistry and kit used for sequencing. Refer to the [Dorado documentation](https://software-docs.nanoporetech.com/dorado/latest/models/list/) for the full model list.

#### Modified base calling

To call modified bases simultaneously with standard basecalling, supply one or more modification models with `--modified_bases_models` (comma-separated, no spaces):

```bash
--model dna_r10.4.1_e8.2_400bps_sup@v5.0.0 \
--modified_bases_models dna_r10.4.1_e8.2_400bps_sup@v5.0.0_6mA@v3
```

#### GPU requirements

Basecalling is GPU-accelerated and requires a CUDA-capable GPU. On the Sanger HPC the pipeline automatically requests GPU nodes via LSF. When running locally, ensure your container runtime has GPU access (`--gpus all` for Docker; `--nv` for Singularity).

### Dependencies

All software dependencies are containerised. No local tool installations are required beyond Nextflow and a container runtime with GPU support for basecalling.

## Software versions

| Software      | Version | Image                                               |
| ------------- | ------- | --------------------------------------------------- |
| Dorado (cuda) | 1.3.1   | `quay.io/sangerpathogens/cuda_dorado:1.3.1`         |
| pod5          | 0.3.6   | `quay.io/sangerpathogens/pod5:0.3.6`                |
| Samtools      | 1.19.2  | `quay.io/biocontainers/samtools:1.19.2--h50ea8bc_1` |
| PycoQC        | 2.5.2   | `quay.io/biocontainers/pycoqc:2.5.2--py_0`          |

## Troubleshooting

- **No GPU available**: basecalling requires a CUDA GPU. On the Sanger HPC, ensure you are submitting to a GPU-enabled queue. Locally, ensure your container runtime is configured with GPU pass-through.
- **Mixed file formats in `--raw_read_dir`**: FAST5 and POD5 files cannot be mixed in the same input directory. Separate them into distinct directories and run the pipeline independently for each.
- **Basecalling model not found**: verify the model name against the [Dorado model list](https://software-docs.nanoporetech.com/dorado/latest/models/list/). For versioned models the full string (e.g. `dna_r10.4.1_e8.2_400bps_sup@v5.0.0`) must match exactly.
- **Empty metadata file**: if `--additional_metadata` is provided but the file is empty, the pipeline will exit with an error. Check the file contains the expected `ID,barcode` header and at least one data row.
- **Resuming a failed run**: add `-resume` to your command to restart from cached intermediate results.
- For further help, check `.nextflow.log` and the per-process `.command.log` logs in the `work/` directory.

Sanger users may find [this page](https://ssg-confluence.internal.sanger.ac.uk/spaces/PaMI/pages/181078206/General+pipeline+info#Generalpipelineinfo-Troubleshootingafailedpipelinerunandsendingabugreport) useful for troubleshooting Nextflow pipeline runs.

## Issues and Contributions

**GitHub users:** if you find an issue with this pipeline or would like to suggest an improvement, please log an issue or open a pull request on this repository.

**Sanger users:** if you need internal support, you can raise an issue on the PAM Freshservice portal: https://sanger.freshservice.com/support/catalog/items/426
