//
// Check input manifest and produce assembly channels
//

workflow MANIFEST_PARSE {
    take:
    manifest // file: /path/to/manifest.csv

    main:

    manifest
        .ifEmpty { exit 1, "File is empty / Cannot find file at ${manifest}" }
        .splitCsv(header:true, strip:true, sep:',')
        .map { row -> parse_row(row) }
        .set { to_basecall_ch }

    emit:
    to_basecall_ch = to_basecall_ch
}

def parse_row(HashMap row) {
    def dir = file(row.unbasecalled_dir)
    def squiggle_files = file("${dir}/*.{fast5,pod5}")
    
    def meta = [:]
    meta.ID     = dir.name
    meta.format = validateSingleFormat(squiggle_files, "--manifest entry ${dir})")

    return tuple(meta, squiggle_files)
}

def cli_parse(cli_input) {
    def dir = file(cli_input)
    def files = file("${dir}/*.{fast5,pod5}", checkIfExists: true)

    def meta = [:]
    meta.ID     = dir.name
    meta.format = validateSingleFormat(files, "--raw_read_dir (${dir})")
    
    return tuple(meta, files)
}

def uniqueExtensions(List files) {
    return files.collect { collected_files -> collected_files.extension }.unique()
}

// Validates a list of files all share one extension.
// source is just a string to identify the source of the files in error messages.
def validateSingleFormat(List files, String source) {
    def formats = uniqueExtensions(files)
    if (formats.size() != 1) {
        exit 1, "Multiple signal filetypes ${formats} found in ${source}. Please separate filetypes into distinct directories and process independently."
    }
    return formats[0]
}