#!/usr/bin/env fish

set archiver_formats tar
set compressor_formats bz2 gz lz4 xz zstd
set arch_and_comp_formats 7z rar zip
set formats $archiver_formats $compressor_formats $arch_and_comp_formats

set options 'h/help' 'n/name=' 't/timestamp' 'f/format=!validate_format'

function validate_format
    if not contains $_flag_value $formats
        echo "$_flag_value archive is not supported" >&2
        return 1
    end
end

function print_help
    echo -es "Archive and compressor wrapper\n" \
        "Supported formats: $formats" >&2
    echo "Usage: compress" \
        "[-h | --help]" \
        "[-n | --name archive_name]" \
        "[-t | --timestamp]" \
        "[-f | --format archive_format]" \
        "file1 [file2, file3, ...]" >&2
    echo -es \
        "-h, --help\t\tPrint this help\n" \
        "-n, --name\t\tSpecify archive name,\n" \
                "\t\t\tif archive name is not provided, default name will be used; \n" \
                "\t\t\tif $(string join '/' $compressor_formats) format used on single file, name will be ignored\n" \
        "-t, --timestamp\t\tAdd timestamp to filename\n" \
        "-f, --format\t\tSpecify archive format, zip is default" >&2
end

function create_tarball
    tar --force-local -cvf $tarball $files
end

# Script main code

argparse $options -- $argv
or return 1

if set -q _flag_help; or test (count $argv) -eq 0
    print_help
    return
end

if not set -q _flag_name
    set _flag_name archive
end

if set -q _flag_timestamp
    set _flag_name "$_flag_name@$(date -Iseconds)"
end

if not set -q _flag_format
    echo "No format specified, using zip" >&2
    set _flag_format zip
end

set tarball "$_flag_name.tar"

set files $argv

if contains $_flag_format $compressor_formats
    if test (count $files) -gt 1 -o -d $files
        echo "Too many files, packing with tar first" >&2
        create_tarball
        set _flag_name $tarball
    else
        set _flag_name $files
    end
end

switch $_flag_format
    case tar
        create_tarball
    case bz2
        bzip2 $_flag_name
    case gz
        gzip $_flag_name
    case lz4
        lz4 $_flag_name
    case xz
        xz $_flag_name
    case zstd
        zstd $_flag_name
    case 7z
        7z a "$_flag_name" $files
    case rar
        rar a "$_flag_name" $files
    case zip
        zip "$_flag_name" $files
end

