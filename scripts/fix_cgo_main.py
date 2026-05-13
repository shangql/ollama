#!/usr/bin/env python3
"""
fix_cgo_main.py - 修改 Mach-O 对象文件中的 _main 符号名，避免与 Go 的 main 冲突。

CGO 生成的 _cgo_main.c 包含一个 dummy main() 函数，在外部链接模式下会与 Go
运行时的 main() 产生重复符号错误。此脚本将 _main 重命名为 __cgo_dummy_main。

用法：fix_cgo_main.py <input.o> <output.o>
"""

import struct
import sys

def fix_main_symbol(input_path, output_path):
    with open(input_path, "rb") as f:
        data = bytearray(f.read())

    magic = struct.unpack("<I", data[:4])[0]
    if magic != 0xfeedfacf:
        print(f"Error: Not a 64-bit Mach-O file (magic={hex(magic)})", file=sys.stderr)
        sys.exit(1)

    # Parse mach_header_64
    ncmds = struct.unpack("<I", data[16:20])[0]

    # Find LC_SYMTAB
    offset = 32  # After mach_header_64
    symtab_offset = None
    symtab_nsyms = None
    strtab_offset = None
    strtab_size = None

    for _ in range(ncmds):
        cmd, cmdsize = struct.unpack("<II", data[offset:offset+8])
        if cmd == 0x2:  # LC_SYMTAB
            symoff, nsyms, stroff, strsize = struct.unpack("<IIII", data[offset+8:offset+24])
            symtab_offset = symoff
            symtab_nsyms = nsyms
            strtab_offset = stroff
            strtab_size = strsize
            break
        offset += cmdsize

    if symtab_offset is None:
        print("Error: LC_SYMTAB not found", file=sys.stderr)
        sys.exit(1)

    # Find _main in the string table
    main_str_offset = None
    for i in range(symtab_nsyms):
        off = symtab_offset + i * 16  # nlist_64
        n_strx = struct.unpack("<I", data[off:off+4])[0]
        str_end = data.index(0, strtab_offset + n_strx)
        sym_name = data[strtab_offset + n_strx:str_end].decode('utf-8')
        if sym_name == "_main":
            main_str_offset = strtab_offset + n_strx
            break

    if main_str_offset is None:
        print(f"Warning: _main symbol not found in {input_path}", file=sys.stderr)
        # Just copy the file as-is
        with open(output_path, "wb") as f:
            f.write(data)
        return

    # Replace _main with __cgo_dummy_main in the string table
    # The new name is 2 chars longer, so we need to shift the string table
    old_name = b"_main"
    new_name = b"__cgo_dummy_main"

    # Build new string table
    new_strtab = bytearray()
    new_offset = 0
    str_mapping = {}  # old offset -> new offset

    # Copy strings one by one, replacing _main
    pos = strtab_offset
    while pos < strtab_offset + strtab_size:
        str_end = data.index(0, pos)
        s = data[pos:str_end+1]  # include null terminator
        old_abs_offset = pos

        if s[:-1] == old_name:
            s = new_name + b'\0'

        str_mapping[old_abs_offset - strtab_offset] = new_offset
        new_strtab.extend(s)
        pos = str_end + 1
        new_offset += len(s)

    # Pad to maintain alignment (8-byte aligned)
    while len(new_strtab) % 8 != 0:
        new_strtab.append(0)

    # Update symbol table entries to point to new string offsets
    for i in range(symtab_nsyms):
        off = symtab_offset + i * 16
        n_strx = struct.unpack("<I", data[off:off+4])[0]
        if n_strx in str_mapping:
            data[off:off+4] = struct.pack("<I", str_mapping[n_strx])

    # Build new file
    new_strtab_size = len(new_strtab)
    size_diff = new_strtab_size - strtab_size

    if size_diff == 0:
        # Same size, just replace in place
        data[strtab_offset:strtab_offset+strtab_size] = new_strtab[:strtab_size]
    else:
        # Need to shift everything after the string table
        new_data = bytearray()

        # Copy everything up to and including the string table
        new_data.extend(data[:strtab_offset])
        new_data.extend(new_strtab)

        # Copy everything after the string table
        remaining_start = strtab_offset + strtab_size
        new_data.extend(data[remaining_start:])

        # Update the symtab_command with new strsize
        offset = 32
        for _ in range(ncmds):
            cmd, cmdsize = struct.unpack("<II", new_data[offset:offset+8])
            if cmd == 0x2:  # LC_SYMTAB
                # Update strsize at offset+20
                new_data[offset+20:offset+24] = struct.pack("<I", new_strtab_size)
                break
            offset += cmdsize

        data = new_data

    with open(output_path, "wb") as f:
        f.write(data)

    print(f"Fixed: {input_path} -> {output_path} (_main -> __cgo_dummy_main)")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <input.o> <output.o>", file=sys.stderr)
        sys.exit(1)
    fix_main_symbol(sys.argv[1], sys.argv[2])
