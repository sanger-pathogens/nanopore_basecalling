workflow READ_MANIFEST_OF_DIRS {

    take:
    read_dir_manifest // file: /path/to/manifest.csv with columns: Sample_ID, reads_dir

    main:
    Channel
        .fromPath( read_dir_manifest )
        .ifEmpty { exit 1, "File is empty / Cannot find file at ${read_dir_manifest}" }
        .splitCsv( header:true, strip:true, sep:',' )
        .map { row ->
            def meta = [ID: row.Sample_ID?.toString()?.trim()]
            def reads_dir = file(row.reads_dir?.toString()?.trim())
            [ meta, reads_dir ]
        }
        .set { sample_dirs }

    sample_dirs
        .flatMap { meta, reads_dir ->
            reads_dir.toFile().listFiles()
                .findAll { it.name.endsWith('.fast5') || it.name.endsWith('.pod5') }
                .collect { f -> [ meta, file(f) ] }
        }
        .set { raw_reads }

    emit:
    raw_reads
}
