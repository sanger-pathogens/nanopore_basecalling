# Nanopore Basecalling

This pipeline processes Nanopore sequencing data in POD5 or FAST5 formats, supporting file conversion, basecalling, demultiplexing, and quality control.

## Usage

Run the minimal pipeline with:

```
nextflow run my-pipeline-importing-this-workflow/main.nf \
--raw_read_dir <directory containing FAST5/POD5 files> \
--barcode_kit_name <name of ONT barcoding kit used for multiplexing>
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

details for what is in the files can be found here
[Custom Barocde arrangements](https://github.com/nanoporetech/dorado/blob/release-v0.9/documentation/CustomBarcodes.md)

## Default Parameters

Below are the default pipeline parameters:

```
--min_qscore = 9
```

```
--basecall_model = "sup"
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
