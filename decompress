#!/usr/bin/env fish

set options 'h/help'
set archiver_formats tar
set bzip2 bz2 tar.bz2 tbz
set gzip gz tar.gz tgz
set lz4 lz4 tar.lz4
set xz xz tar.xz txz
set zstd zst tar.zst tzst
set compressor_formats $bzip2 $gzip $lz4 $xz $zstd
set arch_and_comp_formats 7z rar zip
set formats $archiver_formats $compressor_formats $arch_and_comp_formats

function print_help
    echo -es "Unarchive and uncompress wrapper\n" \
        "Supported formats: $formats\n" \
        "Also able to use MIME types and detect ZIP magic sequence"
    echo "Usage: uncompress" \
        "[-h | --help]" \
        "file1 [file2, file3, ...]" >&2
    echo -es \
        "-h, --help\t\tPrint this help"
end

function get_extension -a file
    set bname (basename $file)
    set extension (string join '.' (string split '.' $bname)[2..])
    echo $extension
end

function extract_by_extension -a archive extension
    switch $extension
        case tar
            tar --force-local -xvf $archive
        case tar.bz2 tbz
            bzcat $archive | tar xf -
        case bz2
            bzip2 -d $archive
        case tar.gz tgz
            zcat $archive | tar xf -
        case gz
            gzip -d $archive
        case tar.lz4
            lz4cat $archive | tar xf -
        case lz4
            lz4 $archive
        case tar.xz txz
            xzcat $archive | tar xf -
        case xz
            xz -d $archive
        case tar.zst tzst
            zstdcat $archive | tar xf -
        case zst
            zstd -d $archive
        case 7z
            7z x $archive
        case rar
            if type -q rar
                rar x $archive
            else
                unrar x $archive
            end
        case zip
            unzip $archive
    end
    or return 1
end

function extract_by_mime -a archive
    set possible_extensions (string split ' ' (file --extension $archive))[2]
    set possible_extensions (string split '/' $possible_extensions)

    for extension in $possible_extensions
        extract_by_extension $archive $extension
        and return
    end

    return 1
end

# Script main code

argparse $options -- $argv
or return 1

if set -q _flag_help; or test (count $argv) -eq 0
    print_help
    return
end

set final_status 0

for archive in $argv
    set extension (get_extension $archive)

    if contains $extension $formats
        extract_by_extension $archive $extension
    else
        echo "Unable to match $archive extension, trying MIME-type detection" >&2
        extract_by_mime $archive
        and continue

        echo "Checking if $archive is secretly a ZIP archive" >&2
        if test (head -c 4 $archive | base64) = "UEsDBA=="
            unzip $archive
            continue
        end

        echo "Extraction of $archive failed" >&2
        set final_status 1
    end
end

return $final_status
