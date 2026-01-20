# Nanopore Basecalling

This pipeline processes Nanopore sequencing data in POD5 or FAST5 formats, supporting file conversion, basecalling, demultiplexing, and quality control.

## Usage

Run the minimal pipeline with:

```
nextflow run main.nf \
--raw_read_dir <directory containing FAST5/POD5 files> \
--barcode_kit_name <name of ONT barcoding kit used for multiplexing>
```

It is important to note that the pipeline will by default choose the latest "sup" model to use. To change this, use the `--model` flag.

This can be set to either a level of basecalling

```
--model hac
```

or a specific model

```
--model dna_r10.4.1_e8.2_400bps_sup@v5.0.0
```

### Additional Parameters

Metadata CSV (Optional)

Provide a CSV file to assign metadata according to barcode numbers:

```
--additional_metadata <CSV mapping sample IDs to barcodes>
```

The CSV format should be:

```
ID,barcode
Sample1,01
```

Custom Barcode Kits (Optional)

To specify custom kits, use the following parameters in addition to --barcode_kit_name:

```
--barcode_arrangement <custom arrangement toml>
--barcode_sequences <my custom barcodes as fasta>
```

Details for what is in the files can be found in [here](https://github.com/nanoporetech/dorado/blob/release-v0.9/documentation/CustomBarcodes.md)

Modified bases aware basecalling (Optional)

To specify models which are away of modified bases please supply

```
--modified_bases_models <model name>
```

for example

```
--modified_bases_models dna_r10.4.1_e8.2_400bps_sup@v5.0.0_6mA@v3,dna_r10.4.1_e8.2_400bps_sup@v5.0.0_4mC_5mC@v3
```

You should choose an appropiate model matching the input for --model

## Default Parameters

Below are the default pipeline parameters:

```
--min_qscore = 9
```

```
--model = "sup"
```

```
--trim_adapters = "all"
```

```
--read_format = "fastq"
```

```
--save_fastqs = true
```
